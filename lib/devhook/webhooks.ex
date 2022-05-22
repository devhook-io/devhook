defmodule Devhook.Webhooks do
  @moduledoc """
  The Webhooks context.
  """

  import Ecto.Query, warn: false
  alias Devhook.Repo

  alias Devhook.Webhooks.Webhook

  @doc """
  Returns the list of webhooks.

  ## Examples

      iex> list_webhooks()
      [%Webhook{}, ...]

  """
  def list_webhooks do
    Repo.all(Webhook)
  end

  @doc """
  Gets a single webhook.

  Raises `Ecto.NoResultsError` if the Webhook does not exist.

  ## Examples

      iex> get_webhook!(123)
      %Webhook{}

      iex> get_webhook!(456)
      ** (Ecto.NoResultsError)

  """
  def get_webhook!(id), do: Repo.get!(Webhook, id)

  def get_auth_webhook(webhook_uid, user_uid),
    do: Repo.get_by(Webhook, uid: webhook_uid, user_uid: user_uid) |> Repo.preload(:user)

  @doc """
  Creates a webhook.

  ## Examples

      iex> create_webhook(%{field: value})
      {:ok, %Webhook{}}

      iex> create_webhook(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_webhook(attrs \\ %{}) do
    %Webhook{}
    |> Webhook.changeset(attrs)
    |> Repo.insert()
  end

  def toggle_webhook(%Webhook{} = webhook, bool) do
    update_webhook(webhook, %{disabled: bool})
  end

  def get_active_webhook(webhook_uid) do
    Repo.get_by(Webhook, uid: webhook_uid, disabled: false)
    |> Repo.preload(:user)
  end

  def get_active_auth_webhook(webhook_uid, user_uid) do
    Repo.get_by(Webhook, user_uid: user_uid, uid: webhook_uid, disabled: false)
  end

  def get_all_auth_webhooks(user_uid) do
    Webhook |> where(user_uid: ^user_uid) |> Repo.all()
  end

  def get_open_webhook(webhook_uid) do
    from(w in Webhook,
      where: w.uid == ^webhook_uid,
      where: w.always_accept == true or w.disabled == false,
      preload: :user
    )
    |> Repo.one()
  end

  @doc """
  Updates a webhook.

  ## Examples

      iex> update_webhook(webhook, %{field: new_value})
      {:ok, %Webhook{}}

      iex> update_webhook(webhook, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_webhook(%Webhook{} = webhook, attrs) do
    webhook
    |> Webhook.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a webhook.

  ## Examples

      iex> delete_webhook(webhook)
      {:ok, %Webhook{}}

      iex> delete_webhook(webhook)
      {:error, %Ecto.Changeset{}}

  """
  def delete_webhook(%Webhook{} = webhook) do
    Repo.delete(webhook)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking webhook changes.

  ## Examples

      iex> change_webhook(webhook)
      %Ecto.Changeset{data: %Webhook{}}

  """
  def change_webhook(%Webhook{} = webhook, attrs \\ %{}) do
    Webhook.changeset(webhook, attrs)
  end
end
