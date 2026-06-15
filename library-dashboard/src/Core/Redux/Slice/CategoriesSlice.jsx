import { createSlice } from "@reduxjs/toolkit";
import { getCategory, createCategory } from "../Thunks/CategoriesThunk";

export const categorySlice = createSlice({
  name: "category",

  initialState: {
    categories: [],
    loading: false,
    error: null,
    success: false,
  },

  reducers: {},

  extraReducers: (builder) => {
    builder

    
      .addCase(getCategory.pending, (state) => {
        state.loading = true;
        state.error = null;
      })

      .addCase(getCategory.fulfilled, (state, action) => {
        state.loading = false;
        state.categories = action.payload?.data || action.payload || [];
      })

      .addCase(getCategory.rejected, (state, action) => {
        state.loading = false;
        state.error = action.error?.message;
      })

     
      .addCase(createCategory.pending, (state) => {
        state.loading = true;
        state.error = null;
        state.success = false;
      })

      .addCase(createCategory.fulfilled, (state, action) => {
        state.loading = false;
        state.success = true;

        const newCategory = action.payload?.data || action.payload;

        if (newCategory) {
          state.categories.push(newCategory);
        }
      })

      .addCase(createCategory.rejected, (state, action) => {
        state.loading = false;
        state.success = false;
        state.error = action.error?.message;
      });
  },
});

export default categorySlice.reducer;