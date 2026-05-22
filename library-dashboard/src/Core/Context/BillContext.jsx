import { createContext, useContext, useState } from "react";
import axiosClient from "../Api/aixos";

const BillsContext = createContext();

export const BillsProvider = ({ children }) => {
  const [bills, setBills] = useState([]);
  const [selectedBill, setSelectedBill] = useState(null);

  const getBills = async () => {
    const { data } = await axiosClient.get("/bills");
    setBills(data);
  };

  const getBill = async (id) => {
    const { data } = await axiosClient.get(`/bills/${id}`);
    setSelectedBill(data);
  };

  return (
    <BillsContext.Provider value={{ bills, selectedBill, getBills, getBill }}>
      {children}
    </BillsContext.Provider>
  );
};

export const useBills = () => useContext(BillsContext);