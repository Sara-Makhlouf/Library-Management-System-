import { createSlice } from "@reduxjs/toolkit";
import { getCategory, createCategory } from "../Thunks/CategoriesThunk";
import { addAsyncCases } from "../utils/reduxHelpers";

export const categorySlice = createSlice({
  name: "category",
  initialState: {
    title: null,
  },
  reducers: {},
  extraReducers: (builder) => {
    addAsyncCases(builder, getCategory);
    addAsyncCases(builder, createCategory);
  },
});

export default categorySlice.reducer;
