import axios from "axios";
import { getAuthConfig } from "../../Api/aixos";
import { createApiThunk } from "../utils/reduxHelpers";

export const getAllTransactions = createApiThunk(
  "adminTransactions/getAllTransactions",
  async (status = null) => {
    const response = await axios.get(`/admin/transactions`, {
      ...getAuthConfig(),
      params: status ? { status } : {},
    });
    return response.data;
  }
);

export const checkoutTransaction = createApiThunk(
  "adminTransactions/checkoutTransaction",
  async (checkoutData) => {
    const response = await axios.post(
      `/admin/transactions/checkout`,
      checkoutData,
      getAuthConfig()
    );
    return response.data;
  }
);
