import api from "../../Api/aixos";
import { createApiThunk } from "../utils/reduxHelpers";

export const getTotalPaidOrder = createApiThunk(
  "bill/getTotalPaidOrder",
  async () => {
    const response = await api.get("/statistics/total-paid-orders");
    return response.data;
  }
);

export const getTotalBorrows = createApiThunk(
  "bill/getTotalBorrows",
  async () => {
    const response = await api.get("/statistics/total-borrows");
    return response.data;
  }
);
