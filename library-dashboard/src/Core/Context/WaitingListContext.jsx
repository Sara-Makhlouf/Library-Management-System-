import { createContext, useContext, useState } from "react";
import axiosClient from "../Api/aixos";

const WaitingListContext = createContext();

export const WaitingListProvider = ({ children }) => {
  const [waitingList, setWaitingList] = useState([]);

  const getWaitingList = async () => {
    const { data } = await axiosClient.get("/waiting-list");
    setWaitingList(data);
  };

  const deleteWaiting = async (id) => {
    await axiosClient.delete(`/waiting-list/${id}`);
    setWaitingList((prev) => prev.filter((w) => w.id !== id));
  };

  return (
    <WaitingListContext.Provider value={{ waitingList, getWaitingList, deleteWaiting }}>
      {children}
    </WaitingListContext.Provider>
  );
};

export const useWaitingList = () => useContext(WaitingListContext);