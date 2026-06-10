import { createContext, useContext, useState } from "react";
import axiosClient from "../Api/aixos";

const TransactionsContext = createContext();

export const TransactionsProvider = ({ children }) => {
  const [transactions, setTransactions] = useState([]);
  const [selectedTransaction, setSelectedTransaction] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  const getTransactions = async () => {
    try {
      setLoading(true);
      setError(null);
      const { data } = await axiosClient.get("/transactions");
      setTransactions(data);
    } catch (err) {
      setError(err.response?.data?.message || err.message);
      console.error("Get Transactions Error:", err);
    } finally {
      setLoading(false);
    }
  };

  const getTransaction = async (id) => {
    try {
      setLoading(true);
      setError(null);
      const { data } = await axiosClient.get(`/transactions/${id}`);
      setSelectedTransaction(data);
    } catch (err) {
      setError(err.response?.data?.message || err.message);
      console.error("Get Transaction Error:", err);
    } finally {
      setLoading(false);
    }
  };

  return (
    <TransactionsContext.Provider
      value={{
        transactions,
        selectedTransaction,
        loading,
        error,
        getTransactions,
        getTransaction,
      }}
    >
      {children}
    </TransactionsContext.Provider>
  );
};

export const useTransactions = () => useContext(TransactionsContext);
