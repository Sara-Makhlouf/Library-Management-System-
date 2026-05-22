import { createContext, useContext, useState } from "react";
import axiosClient from "../Api/aixos";

const BooksContext = createContext();

export const BooksProvider = ({ children }) => {
  const [books, setBooks] = useState([]);
  const [selectedBook, setSelectedBook] = useState(null);
  const [loading, setLoading] = useState(false);

  const getBooks = async () => {
    try {
      setLoading(true);

      const { data } = await axiosClient.get("/books");

      setBooks(data);
    } catch (error) {
      console.error("Get Books Error:", error);
    } finally {
      setLoading(false);
    }
  };

  const getBook = async (id) => {
    try {
      const { data } = await axiosClient.get(`/books/${id}`);

      setSelectedBook(data);
    } catch (error) {
      console.error("Get Book Error:", error);
    }
  };

  const createBook = async (bookData) => {
    try {
      const { data } = await axiosClient.post("/books", bookData);

      setBooks((prev) => [...prev, data]);
      return data;
    } catch (error) {
      console.error("Create Book Error:", error);
    }
  };

  const updateBook = async (id, bookData) => {
    try {
      const { data } = await axiosClient.put(`/books/${id}`, bookData);

      setBooks((prev) =>
        prev.map((b) => (b.id === id ? data : b))
      );

      return data;
    } catch (error) {
      console.error("Update Book Error:", error);
    }
  };

  const deleteBook = async (id) => {
    try {
      await axiosClient.delete(`/books/${id}`);

      setBooks((prev) => prev.filter((b) => b.id !== id));
    } catch (error) {
      console.error("Delete Book Error:", error);
    }
  };

  return (
    <BooksContext.Provider
      value={{
        books,
        selectedBook,
        loading,
        getBooks,
        getBook,
        createBook,
        updateBook,
        deleteBook,
      }}
    >
      {children}
    </BooksContext.Provider>
  );
};

export const useBooks = () => useContext(BooksContext);