import { createContext, useContext, useState } from "react";
import axiosClient from "../Api/aixos";

const TransactionsContext = createContext();

export const TransactionsProvider = ({ children }) => {
  const [transactions, setTransactions] = useState([]);
  const [selectedTransaction, setSelectedTransaction] = useState(null);

  const getTransactions = async () => {
    const { data } = await axiosClient.get("/transactions");
    setTransactions(data);
  };

  const getTransaction = async (id) => {
    const { data } = await axiosClient.get(`/transactions/${id}`);
    setSelectedTransaction(data);
  };

  return (
    <TransactionsContext.Provider
      value={{
        transactions,
        selectedTransaction,
        getTransactions,
        getTransaction,
      }}
    >
      {children}
    </TransactionsContext.Provider>
  );
};

export const useTransactions = () => useContext(TransactionsContext);