import { createContext, useContext, useState } from "react";
import axiosClient from "../Api/aixos";

const UsersContext = createContext();

export const UsersProvider = ({ children }) => {
  const [users, setUsers] = useState([]);
  const [selectedUser, setSelectedUser] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  // GET ALL USERS
  const getUsers = async () => {
    try {
      setLoading(true);
      setError(null);
      const { data } = await axiosClient.get("/users");
      setUsers(data);
    } catch (err) {
      setError(err.response?.data?.message || err.message);
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  // GET ONE USER
  const getUser = async (id) => {
    try {
      setLoading(true);
      setError(null);
      const { data } = await axiosClient.get(`/users/${id}`);
      setSelectedUser(data);
    } catch (err) {
      setError(err.response?.data?.message || err.message);
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
        error,
        getUsers,
        getUser,
      }}
    >
      {children}
    </UsersContext.Provider>
  );
};

export const useUsers = () => useContext(UsersContext);
