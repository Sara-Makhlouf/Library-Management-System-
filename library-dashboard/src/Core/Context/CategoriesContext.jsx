import { createContext, useContext, useState } from "react";
import axiosClient from "../Api/aixos";

const CategoryContext = createContext();

export const CategoryProvider = ({ children }) => {
  const [categories, setCategories] = useState([]);

  const getCategories = async () => {
    const { data } = await axiosClient.get("/categories/list");
    setCategories(data);
  };

  const createCategory = async (name) => {
    const { data } = await axiosClient.post("/categories", { name });
    setCategories((prev) => [...prev, data]);
  };

  return (
    <CategoryContext.Provider value={{ categories, getCategories, createCategory }}>
      {children}
    </CategoryContext.Provider>
  );
};

export const useCategories = () => useContext(CategoryContext);