import { createContext, useContext, useState } from "react";
import axiosClient from "../Api/aixos";

const AuthorContext = createContext();

export const AuthorProvider = ({ children }) => {
  const [authors, setAuthors] = useState([]);
  const [selectedAuthor, setSelectedAuthor] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  const getAuthors = async () => {
    try {
      setLoading(true);
      setError(null);
      const { data } = await axiosClient.get("/authors");
      setAuthors(data);
    } catch (err) {
      setError(err.response?.data?.message || err.message);
      console.error("Get Authors Error:", err);
    } finally {
      setLoading(false);
    }
  };

  const getAuthor = async (id) => {
    try {
      setLoading(true);
      setError(null);
      const { data } = await axiosClient.get(`/authors/${id}`);
      setSelectedAuthor(data);
    } catch (err) {
      setError(err.response?.data?.message || err.message);
      console.error("Get Author Error:", err);
    } finally {
      setLoading(false);
    }
  };

  const createAuthor = async (authorData) => {
    try {
      setError(null);
      const { data } = await axiosClient.post("/authors", authorData);
      setAuthors((prev) => [...prev, data]);
      return data;
    } catch (err) {
      setError(err.response?.data?.message || err.message);
      console.error("Create Author Error:", err);
      throw err;
    }
  };

  const updateAuthor = async (id, authorData) => {
    try {
      setError(null);
      const { data } = await axiosClient.put(`/authors/${id}`, authorData);

      setAuthors((prev) =>
        prev.map((a) => (a.id === id ? data : a))
      );

      return data;
    } catch (err) {
      setError(err.response?.data?.message || err.message);
      console.error("Update Author Error:", err);
      throw err;
    }
  };

  const deleteAuthor = async (id) => {
    try {
      setError(null);
      await axiosClient.delete(`/authors/${id}`);

      setAuthors((prev) => prev.filter((a) => a.id !== id));
    } catch (err) {
      setError(err.response?.data?.message || err.message);
      console.error("Delete Author Error:", err);
      throw err;
    }
  };

  return (
    <AuthorContext.Provider
      value={{
        authors,
        selectedAuthor,
        loading,
        error,
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
