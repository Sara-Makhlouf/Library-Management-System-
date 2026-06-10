import api from "../../Api/aixos";
import { createApiThunk } from "../utils/reduxHelpers";

export const getTotoalbillsRevenue = createApiThunk(
  "finance/gettotalbillsrevenue",
  async () => {
    const response = await api.get("/bills/total-revenue/");
    return response.data;
  }
);
