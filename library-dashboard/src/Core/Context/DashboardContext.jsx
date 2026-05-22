import { createContext, useContext, useEffect, useState } from "react";
import axiosClient from "../Api/aixos";

const DashboardContext = createContext();

export const DashboardProvider = ({ children }) => {
  const [dashboardStats, setDashboardStats] = useState(null);
  const [topBorrowedBooks, setTopBorrowedBooks] = useState([]);
  const [waitingList, setWaitingList] = useState([]);
  const [totalRevenue, setTotalRevenue] = useState(null);

  const [loading, setLoading] = useState(false);

  const dashboardStatsApi = async () => {
    try {
      const { data } = await axiosClient.get("/dashboard-stats");

      setDashboardStats(data);
    } catch (error) {
      console.error(error);
    }
  };

  const topBorrowedBooksApi = async () => {
    try {
      const { data } = await axiosClient.get(
        "/transactions/top-borrowed"
      );

      setTopBorrowedBooks(data);
    } catch (error) {
      console.error(error);
    }
  };

  const waitingListApi = async () => {
    try {
      const { data } = await axiosClient.get("/waiting-list");

      setWaitingList(data);
    } catch (error) {
      console.error(error);
    }
  };

  const totalRevenueApi = async () => {
    try {
      const { data } = await axiosClient.get(
        "/admin/bills/total-revenue"
      );

      setTotalRevenue(data);
    } catch (error) {
      console.error(error);
    }
  };

 const fetchDashboardData = async () => {
  setLoading(true);

  try {
    await dashboardStatsApi();
  } catch (e) {
    console.error("dashboardStatsApi", e);
  }

  try {
    await topBorrowedBooksApi();
  } catch (e) {
    console.error("topBorrowedBooksApi", e);
  }

  try {
    await waitingListApi();
  } catch (e) {
    console.error("waitingListApi", e);
  }

  try {
    await totalRevenueApi();
  } catch (e) {
    console.error("totalRevenueApi", e);
  }

  setLoading(false);
};
  useEffect(() => {
    fetchDashboardData();
  }, );

  return (
    <DashboardContext.Provider
      value={{
        dashboardStats,
        topBorrowedBooks,
        waitingList,
        totalRevenue,
        loading,

        dashboardStatsApi,
        topBorrowedBooksApi,
        waitingListApi,
        totalRevenueApi,
        fetchDashboardData,
      }}
    >
      {children}
    </DashboardContext.Provider>
  );
};

export const useDashboard = () => useContext(DashboardContext);