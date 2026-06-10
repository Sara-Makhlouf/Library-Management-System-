import { createContext, useState, useContext } from "react";
import axiosClient from "../Api/aixos";

const AuthContext = createContext();

export const AuthProvider = ({ children }) => {
  const [user, setUser] = useState(null);
  const [token, setToken] = useState(localStorage.getItem("empty"));
  const [error, setError] = useState(null);

  const login = async (email, password) => {
    try {
      setError(null);
      const { data } = await axiosClient.post("/login", {
        email,
        password,
      });

      setUser(data.user);
      setToken(data.token);

      localStorage.setItem("token", data.token);

      return data;
    } catch (err) {
      const message = err.response?.data?.message || err.message;
      setError(message);
      throw err;
    }
  };

  const logout = () => {
    setUser(null);
    setToken(null);
    setError(null);
    localStorage.removeItem("token");
  };

  return (
    <AuthContext.Provider value={{ user, token, error, login, logout }}>
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => useContext(AuthContext);
