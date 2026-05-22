import { createContext, useContext, useState } from "react";
import axiosClient from "../Api/aixos";

const UsersContext = createContext();

export const UsersProvider = ({ children }) => {
  const [users, setUsers] = useState([]);
  const [selectedUser, setSelectedUser] = useState(null);
  const [loading, setLoading] = useState(false);

  // GET ALL USERS
  const getUsers = async () => {
    try {
      setLoading(true);
      const { data } = await axiosClient.get("/users");
      setUsers(data);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  // GET ONE USER
  const getUser = async (id) => {
    try {
      setLoading(true);
      const { data } = await axiosClient.get(`/users/${id}`);
      setSelectedUser(data);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  return (
    <UsersContext.Provider
      value={{
        users,
        selectedUser,
        loading,
        getUsers,
        getUser,
      }}
    >
      {children}
    </UsersContext.Provider>
  );
};

export const useUsers = () => useContext(UsersContext);