import api from "../../Api/aixos";
import { createApiThunk } from "../utils/reduxHelpers";

export const fetchBills = createApiThunk("bill/fetchbills", async () => {
  const response = await api.get("/bills");
  return response.data;
});

export const fetchBillsWithId = createApiThunk(
  "bill/fetchbillswithid",
  async (billId) => {
    const response = await api.get(`/bills/${billId}`);
    return response.data;
  }
);

export const fetchBillDelivery = createApiThunk(
  "bill/fetchbilldelivery",
  async () => {
    const response = await api.get(`/bills/delivery-requests`);
    return response.data;
  }
);
