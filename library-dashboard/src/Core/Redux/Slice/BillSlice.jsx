import { createSlice } from "@reduxjs/toolkit";
import { fetchBills, fetchBillsWithId, fetchBillDelivery } from "../Thunks/BillThunk";
import { addAsyncCases } from "../utils/reduxHelpers";

const billSlice = createSlice({
  name: "bill",
  initialState: {
    billSlice: [],
    error: null,
    loading: false,
  },
  extraReducers: (builder) => {
    addAsyncCases(builder, fetchBills, { dataKey: "billSlice" });
    addAsyncCases(builder, fetchBillsWithId);
    addAsyncCases(builder, fetchBillDelivery);
  },
});

export default billSlice.reducer;
