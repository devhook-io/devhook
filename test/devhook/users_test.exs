defmodule Devhook.UsersTest do
  use Devhook.DataCase

  import Devhook.Factory

  alias Devhook.Users

  describe "users" do
    alias Devhook.Users.User

    @valid_attrs %{
      auth0_xid: "some auth0_xid",
      email: "some email",
      first_name: "some first_name",
      last_name: "some last_name"
    }
    @update_attrs %{
      auth0_xid: "some updated auth0_xid",
      email: "some updated email",
      first_name: "some updated first_name",
      last_name: "some updated last_name"
    }
    @invalid_attrs %{auth0_xid: nil, email: nil, first_name: nil, last_name: nil}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Users.create_user()

      user
    end

    test "list_users/0 returns all users" do
      user = insert(:user)
      assert Users.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = insert(:user)
      assert Users.get_user!(user.uid) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Users.create_user(@valid_attrs)
      assert user.auth0_xid == "some auth0_xid"
      assert user.email == "some email"
      assert user.first_name == "some first_name"
      assert user.last_name == "some last_name"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Users.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = insert(:user)
      assert {:ok, %User{} = user} = Users.update_user(user, @update_attrs)
      assert user.auth0_xid == "some updated auth0_xid"
      assert user.email == "some updated email"
      assert user.first_name == "some updated first_name"
      assert user.last_name == "some updated last_name"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = insert(:user)
      assert {:error, %Ecto.Changeset{}} = Users.update_user(user, @invalid_attrs)
      assert user == Users.get_user!(user.uid)
    end

    test "delete_user/1 deletes the user" do
      user = insert(:user)
      assert {:ok, %User{}} = Users.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Users.get_user!(user.uid) end
    end

    test "change_user/1 returns a user changeset" do
      user = insert(:user)
      assert %Ecto.Changeset{} = Users.change_user(user)
    end
  end
end
