defmodule Hr.Messages do
  # Linguist?

  def signed_up_but_unconfirmed do
    {:ok, [messages|_]} = Yomel.decode_file("config/hr_locales/en.yml")
    messages["hr"]["registrations"]["signed_up_but_unconfirmed"]
  end

  def signed_in_successfully do
    {:ok, [messages|_]} = Yomel.decode_file("config/hr_locales/en.yml")
    messages["hr"]["sessions"]["signed_in_successfully"]
  end

  def invalid_email_password do
    {:ok, [messages|_]} = Yomel.decode_file("config/hr_locales/en.yml")
    messages["hr"]["failure"]["invalid"]
  end
end
