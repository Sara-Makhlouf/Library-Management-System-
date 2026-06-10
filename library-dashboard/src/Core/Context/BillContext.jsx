import { createContext, useContext, useState } from "react";
import axiosClient from "../Api/aixos";

const BillsContext = createContext();

export const BillsProvider = ({ children }) => {
  const [bills, setBills] = useState([]);
  const [selectedBill, setSelectedBill] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  const getBills = async () => {
    try {
      setLoading(true);
      setError(null);
      const { data } = await axiosClient.get("/bills");
      setBills(data);
    } catch (err) {
      setError(err.response?.data?.message || err.message);
      console.error("Get Bills Error:", err);
    } finally {
      setLoading(false);
    }
  };

  const getBill = async (id) => {
    try {
      setLoading(true);
      setError(null);
      const { data } = await axiosClient.get(`/bills/${id}`);
      setSelectedBill(data);
    } catch (err) {
      setError(err.response?.data?.message || err.message);
      console.error("Get Bill Error:", err);
    } finally {
      setLoading(false);
    }
  };

  return (
    <BillsContext.Provider value={{ bills, selectedBill, loading, error, getBills, getBill }}>
      {children}
    </BillsContext.Provider>
  );
};

export const useBills = () => useContext(BillsContext);
