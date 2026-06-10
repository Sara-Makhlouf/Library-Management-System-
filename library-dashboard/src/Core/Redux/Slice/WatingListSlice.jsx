import { createSlice } from "@reduxjs/toolkit";
import { getBooksInvaliable } from "../Thunks/WaitingListThunk";
import { addAsyncCases } from "../utils/reduxHelpers";

const initialState = {
  books: null,
  loading: false,
  error: null,
};

const waitingListSlice = createSlice({
  name: "waitingList",
  initialState,
  reducers: {},
  extraReducers: (builder) => {
    addAsyncCases(builder, getBooksInvaliable, { dataKey: "books" });
  },
});

export default waitingListSlice.reducer;
