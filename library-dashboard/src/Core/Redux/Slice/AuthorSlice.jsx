import { createSlice } from "@reduxjs/toolkit";
import { getauthor, createauthor } from "../Thunks/AuthorThunk";

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
    builder

    .addCase(getauthor.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(getauthor.fulfilled, (state, action) => {
        state.loading = false;
        state.author = action.payload;
      })
      .addCase(getauthor.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload;
      })

      .addCase(createauthor.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(createauthor.fulfilled, (state, action) => {
        state.loading = false;
        state.author = action.payload;
      })
      .addCase(createauthor.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload;
      });
  },
});

export default authorSlice.reducer;