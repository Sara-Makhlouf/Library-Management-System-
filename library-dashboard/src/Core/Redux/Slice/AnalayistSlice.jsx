import { createSlice } from "@reduxjs/toolkit";
import { getTotalPaidOrder, getTotalBorrows } from "../Thunks/AnalayistThunk";
import { addAsyncCases } from "../utils/reduxHelpers";

const initialState = {
  analyst: null,
  loading: false,
  error: null,
};

const analystSlice = createSlice({
  name: "analyst",
  initialState,
  reducers: {},
  extraReducers: (builder) => {
    addAsyncCases(builder, getTotalPaidOrder, { dataKey: "analyst" });
    addAsyncCases(builder, getTotalBorrows, { dataKey: "analyst" });
  },
});

export default analystSlice.reducer;
