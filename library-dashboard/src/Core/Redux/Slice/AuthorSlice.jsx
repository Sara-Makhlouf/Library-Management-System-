import { createSlice } from "@reduxjs/toolkit";
import { getauthor } from "../Thunks/AuthorThunk";
import { addAsyncCases } from "../utils/reduxHelpers";

const initialState = {
  author: null,
  loading: false,
  error: null,
};

const authorSlice = createSlice({
  name: "author",
  initialState,
  reducers: {},
  extraReducers: (builder) => {
    addAsyncCases(builder, getauthor, { dataKey: "author" });
  },
});

export default authorSlice.reducer;
