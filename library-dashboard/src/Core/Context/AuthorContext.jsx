import { createContext, useContext, useState } from "react";
import axiosClient from "../Api/aixos";

const AuthorContext = createContext();

export const AuthorProvider = ({ children }) => {
  const [authors, setAuthors] = useState([]);
  const [selectedAuthor, setSelectedAuthor] = useState(null);
  const [loading, setLoading] = useState(false);

  const getAuthors = async () => {
    try {
      setLoading(true);
      const { data } = await axiosClient.get("/authors");
      setAuthors(data);
    } catch (err) {
      console.error("Get Authors Error:", err);
    } finally {
      setLoading(false);
    }
  };

  const getAuthor = async (id) => {
    try {
      setLoading(true);
      const { data } = await axiosClient.get(`/authors/${id}`);
      setSelectedAuthor(data);
    } catch (err) {
      console.error("Get Author Error:", err);
    } finally {
      setLoading(false);
    }
  };

  const createAuthor = async (authorData) => {
    try {
      const { data } = await axiosClient.post("/authors", authorData);
      setAuthors((prev) => [...prev, data]);
      return data;
    } catch (err) {
      console.error("Create Author Error:", err);
    }
  };

  const updateAuthor = async (id, authorData) => {
    try {
      const { data } = await axiosClient.put(`/authors/${id}`, authorData);

      setAuthors((prev) =>
        prev.map((a) => (a.id === id ? data : a))
      );

      return data;
    } catch (err) {
      console.error("Update Author Error:", err);
    }
  };

  const deleteAuthor = async (id) => {
    try {
      await axiosClient.delete(`/authors/${id}`);

      setAuthors((prev) => prev.filter((a) => a.id !== id));
    } catch (err) {
      console.error("Delete Author Error:", err);
    }
  };

  return (
    <AuthorContext.Provider
      value={{
        authors,
        selectedAuthor,
        loading,
        getAuthors,
        getAuthor,
        createAuthor,
        updateAuthor,
        deleteAuthor,
      }}
    >
      {children}
    </AuthorContext.Provider>
  );
};

export const useAuthors = () => useContext(AuthorContext);