import { createSlice } from "@reduxjs/toolkit";
import { getauthor, createauthor ,updateAuthor,deleteAuthor } from "../Thunks/AuthorThunk";

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
      })
      .addCase(deleteAuthor.fulfilled, (state, action) => {
        state.authors = state.authors.filter((author) => author.id !== action.payload);
      })

      .addCase(updateAuthor.fulfilled, (state, action) => {
        const index = state.authors.findIndex((a) => a.id === action.payload.data.id);
        if (index !== -1) {
          state.authors[index] = action.payload.data;
        }
      });
  },
});

export default authorSlice.reducer;