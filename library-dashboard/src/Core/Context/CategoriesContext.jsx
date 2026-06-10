import { createContext, useContext, useState } from "react";
import axiosClient from "../Api/aixos";

const CategoryContext = createContext();

export const CategoryProvider = ({ children }) => {
  const [categories, setCategories] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  const getCategories = async () => {
    try {
      setLoading(true);
      setError(null);
      const { data } = await axiosClient.get("/categories/list");
      setCategories(data);
    } catch (err) {
      setError(err.response?.data?.message || err.message);
      console.error("Get Categories Error:", err);
    } finally {
      setLoading(false);
    }
  };

  const createCategory = async (name) => {
    try {
      setError(null);
      const { data } = await axiosClient.post("/categories", { name });
      setCategories((prev) => [...prev, data]);
      return data;
    } catch (err) {
      setError(err.response?.data?.message || err.message);
      console.error("Create Category Error:", err);
      throw err;
    }
  };

  return (
    <CategoryContext.Provider value={{ categories, loading, error, getCategories, createCategory }}>
      {children}
    </CategoryContext.Provider>
  );
};

export const useCategories = () => useContext(CategoryContext);
