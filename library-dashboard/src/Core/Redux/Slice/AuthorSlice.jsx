import { createSlice } from "@reduxjs/toolkit";
import { getauthor, createauthor } from "../Thunks/AuthorThunk";

const initialState = {
  authors: [],
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
        state.authors = action.payload.data;
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

        if (action.payload?.data) {
          state.authors.push(action.payload.data);
        }
      })
      .addCase(createauthor.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload;
      });
  },
});

export default authorSlice.reducer;