import api from "../../Api/aixos";
import { createApiThunk } from "../utils/reduxHelpers";

export const getDashboardStats = createApiThunk(
  "dashboard/getDashboardStats",
  async () => {
    const response = await api.get(`/dashboard-stats`);
    return response.data;
  }
);

export const getTopBorrowed = createApiThunk(
  "dashboard/getTopBorrowed",
  async () => {
    const response = await api.post("/transactions/top-borrowed");
    return response.data;
  }
);

export const getWeeklySales = createApiThunk(
  "dashboard/getWeeklySales",
  async () => {
    const response = await api.post("/statistics/weekly-sales");
    return response.data;
  }
);

export const getTopSellingBooks = createApiThunk(
  "dashboard/getTopSellingBooks",
  async () => {
    const response = await api.post("/statistics/top-selling-books");
    return response.data;
  }
);

export const getWeeklyBorrows = createApiThunk(
  "dashboard/getWeeklyBorrows",
  async () => {
    const response = await api.post("/statistics/weekly-borrows");
    return response.data;
  }
);
