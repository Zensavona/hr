defmodule Hr.Messages do
  # Linguist?

  def signed_up_but_unconfirmed do
    {:ok, [messages|t]} = Yomel.decode_file("config/hr_locales/en.yml")
    messages["hr"]["registrations"]["signed_up_but_unconfirmed"]
  end
end
