import { createSlice } from "@reduxjs/toolkit";
import { getTotoalbillsRevenue } from "../Thunks/FinanceThunk";
import { addAsyncCases } from "../utils/reduxHelpers";

export const financeSlice = createSlice({
  name: "finance",
  initialState: {
    totalRevenue: null,
  },
  reducers: {},
  extraReducers: (builder) => {
    addAsyncCases(builder, getTotoalbillsRevenue, { dataKey: "totalRevenue" });
  },
});

export default financeSlice.reducer;
