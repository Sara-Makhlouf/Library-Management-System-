import { createContext, useContext, useEffect, useState } from "react";
import axiosClient from "../Api/aixos";

const DashboardContext = createContext();

export const DashboardProvider = ({ children }) => {
  const [dashboardStats, setDashboardStats] = useState(null);
  const [topBorrowedBooks, setTopBorrowedBooks] = useState([]);
  const [waitingList, setWaitingList] = useState([]);
  const [totalRevenue, setTotalRevenue] = useState(null);

  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  const dashboardStatsApi = async () => {
    try {
      const { data } = await axiosClient.get("/dashboard-stats");

      setDashboardStats(data);
    } catch (err) {
      console.error("Dashboard stats error:", err);
      throw err;
    }
  };

  const topBorrowedBooksApi = async () => {
    try {
      const { data } = await axiosClient.get(
        "/transactions/top-borrowed"
      );

      setTopBorrowedBooks(data);
    } catch (err) {
      console.error("Top borrowed books error:", err);
      throw err;
    }
  };

  const waitingListApi = async () => {
    try {
      const { data } = await axiosClient.get("/waiting-list");

      setWaitingList(data);
    } catch (err) {
      console.error("Waiting list error:", err);
      throw err;
    }
  };

  const totalRevenueApi = async () => {
    try {
      const { data } = await axiosClient.get(
        "/admin/bills/total-revenue"
      );

      setTotalRevenue(data);
    } catch (err) {
      console.error("Total revenue error:", err);
      throw err;
    }
  };

 const fetchDashboardData = async () => {
  setLoading(true);
  setError(null);

  try {
    await dashboardStatsApi();
  } catch (e) {
    setError(e.response?.data?.message || e.message);
  }

  try {
    await topBorrowedBooksApi();
  } catch (e) {
    setError(e.response?.data?.message || e.message);
  }

  try {
    await waitingListApi();
  } catch (e) {
    setError(e.response?.data?.message || e.message);
  }

  try {
    await totalRevenueApi();
  } catch (e) {
    setError(e.response?.data?.message || e.message);
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
        error,

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
