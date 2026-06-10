import { createContext, useState, useContext } from "react";
import axiosClient from "../Api/aixos";

const AuthContext = createContext();

export const AuthProvider = ({ children }) => {
  const [user, setUser] = useState(null);
  const [token, setToken] = useState(localStorage.getItem("token"));

  const login = async (email, password) => {
    const { data } = await axiosClient.post("/login", {
      email,
      password,
    });

    setUser(data.user);
    setToken(data.token);

    localStorage.setItem("token", data.token);

    return data;
  };

  const logout = () => {
    setUser(null);
    setToken(null);
    localStorage.removeItem("token");
  };

  return (
    <AuthContext.Provider value={{ user, token, login, logout }}>
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => useContext(AuthContext);