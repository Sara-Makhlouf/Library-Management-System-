import { createContext, useContext, useState } from "react";
import axiosClient from "../Api/aixos";

const WaitingListContext = createContext();

export const WaitingListProvider = ({ children }) => {
  const [waitingList, setWaitingList] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  const getWaitingList = async () => {
    try {
      setLoading(true);
      setError(null);
      const { data } = await axiosClient.get("/waiting-list");
      setWaitingList(data);
    } catch (err) {
      setError(err.response?.data?.message || err.message);
      console.error("Get Waiting List Error:", err);
    } finally {
      setLoading(false);
    }
  };

  const deleteWaiting = async (id) => {
    try {
      setError(null);
      await axiosClient.delete(`/waiting-list/${id}`);
      setWaitingList((prev) => prev.filter((w) => w.id !== id));
    } catch (err) {
      setError(err.response?.data?.message || err.message);
      console.error("Delete Waiting Error:", err);
      throw err;
    }
  };

  return (
    <WaitingListContext.Provider value={{ waitingList, loading, error, getWaitingList, deleteWaiting }}>
      {children}
    </WaitingListContext.Provider>
  );
};

export const useWaitingList = () => useContext(WaitingListContext);
