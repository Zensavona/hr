defmodule Mix.Tasks.Hr.Gen.Model do
  @moduledoc """
  """
  use Mix.Task

  @shortdoc "Generates a Ecto model preconfigured for HR"

  def run(args) do
    switches = [migration: :boolean, binary_id: :boolean, instructions: :string]

    {opts, parsed, _} = OptionParser.parse(args, switches: switches)
    [singular, plural | attrs] = validate_args!(parsed)

    default_opts = Application.get_env(:phoenix, :generators, [])
    opts = Keyword.merge(default_opts, opts)

    attrs = Mix.Phoenix.attrs(attrs)

    # remove email, password_hash, confirmation_token, password_recovery_token
    disallowed = [:email, :email_address, :password, :password_hash,
                  :confirmation_token, :password_recovery_token, :password_reset_token, :unconfirmed_email, :confirmed_at, :confirmation_sent_at, :reset_password_sent_at, :failed_attempts, :locked_at]

    attrs = Enum.filter(attrs, fn({k, v}) -> !Enum.member?(disallowed, k) end)

    attrs = attrs

    binding   = Mix.Phoenix.inflect(singular)
    params    = Mix.Phoenix.params(attrs)
    path      = binding[:path]
    migration = String.replace(path, "/", "_")

    Mix.Phoenix.check_module_name_availability!(binding[:module])

    {assocs, attrs} = partition_attrs_and_assocs(attrs)

    indexes = indexes(plural, assocs)

    binding = binding ++
              [attrs: attrs, plural: plural, types: types(attrs),
               assocs: assocs(assocs), indexes: indexes,
               defaults: defaults(attrs), params: params,
               binary_id: opts[:binary_id]]

    files = [
      {:eex, "model.ex", "web/models/#{path}.ex"},
      {:eex, "model_identity.ex", "web/models/#{path}_identity.ex"},
      {:eex, "model_test.exs", "test/models/#{path}_test.exs"}
    ]

    if opts[:migration] != false do
      files =
        [{:eex, "migration.exs", "priv/repo/migrations/#{timestamp()<>to_string(1)}_create_#{migration}.exs"},
         {:eex, "identities_migration.ex", "priv/repo/migrations/#{timestamp()}_create_#{migration}_identities.exs"}|files]
    end

    Mix.Phoenix.copy_from paths(), "priv/templates/phoenix.gen.hr.model", "", binding, files

    # Print any extra instruction given by parent generators
    Mix.shell.info opts[:instructions] || ""

    if opts[:migration] != false do
      Mix.shell.info """
      Remember to update your repository by running migrations:

          $ mix ecto.migrate
      """
    end
  end

  defp validate_args!([_, plural | _] = args) do
    cond do
      String.contains?(plural, ":") ->
        raise_with_help
      plural != Phoenix.Naming.underscore(plural) ->
        Mix.raise "expected the second argument, #{inspect plural}, to be all lowercase using snake_case convention"
      true ->
        args
    end
  end

  defp validate_args!(_) do
    raise_with_help
  end

  defp raise_with_help do
    Mix.raise """
    mix phoenix.gen.hr.model expects both singular and plural names
    of the generated resource followed by any number of attributes:

        mix phoenix.gen.hr.model User users name:string
    """
  end

  defp partition_attrs_and_assocs(attrs) do
    Enum.partition attrs, fn
      {_, {:references, _}} ->
        true
      {key, :references} ->
        Mix.raise """
        Phoenix generators expect the table to be given to #{key}:references.
        For example:

            mix phoenix.gen.hr.model Comment comments body:text post_id:references:posts
        """
      _ ->
        false
    end
  end

  defp assocs(assocs) do
    Enum.map assocs, fn {key_id, {:references, source}} ->
      key   = String.replace(Atom.to_string(key_id), "_id", "")
      assoc = Mix.Phoenix.inflect key
      {String.to_atom(key), key_id, assoc[:module], source}
    end
  end

  defp indexes(plural, assocs) do
    Enum.map assocs, fn {key, _} ->
      "create index(:#{plural}, [:#{key}])"
    end
  end

  defp timestamp do
    {{y, m, d}, {hh, mm, ss}} = :calendar.universal_time()
    "#{y}#{pad(m)}#{pad(d)}#{pad(hh)}#{pad(mm)}#{pad(ss)}"
  end

  defp pad(i) when i < 10, do: << ?0, ?0 + i >>
  defp pad(i), do: to_string(i)

  defp types(attrs) do
    Enum.into attrs, %{}, fn
      {k, {c, v}} -> {k, {c, value_to_type(v)}}
      {k, v}      -> {k, value_to_type(v)}
    end
  end

  defp defaults(attrs) do
    Enum.into attrs, %{}, fn
      {k, :boolean}  -> {k, ", default: false"}
      {k, _}         -> {k, ""}
    end
  end

  defp value_to_type(:text), do: :string
  defp value_to_type(:uuid), do: Ecto.UUID
  defp value_to_type(:date), do: Ecto.Date
  defp value_to_type(:time), do: Ecto.Time
  defp value_to_type(:datetime), do: Ecto.DateTime
  defp value_to_type(v) do
    if Code.ensure_loaded?(Ecto.Type) and not Ecto.Type.primitive?(v) do
      Mix.raise "Unknown type `#{v}` given to generator"
    else
      v
    end
  end

  defp paths do
    [".", :hr]
  end
end
