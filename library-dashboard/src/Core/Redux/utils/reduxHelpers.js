import { createAsyncThunk } from "@reduxjs/toolkit";

/**
 * Factory for creating async thunks with consistent error handling.
 *
 * @param {string} typePrefix  - Redux action type prefix, e.g. "books/fetchBooks"
 * @param {Function} apiCall   - (arg, thunkAPI) => Promise  — the async work
 * @returns {import("@reduxjs/toolkit").AsyncThunk}
 */
export const createApiThunk = (typePrefix, apiCall) =>
  createAsyncThunk(typePrefix, async (arg, thunkAPI) => {
    try {
      return await apiCall(arg, thunkAPI);
    } catch (error) {
      return thunkAPI.rejectWithValue(
        error.response?.data || error.message
      );
    }
  });

/**
 * Adds the standard pending / fulfilled / rejected cases for an async thunk
 * to a slice's extraReducers builder.
 *
 * @param {import("@reduxjs/toolkit").ActionReducerMapBuilder} builder
 * @param {import("@reduxjs/toolkit").AsyncThunk} thunk
 * @param {object} opts
 * @param {string}   [opts.loadingKey="loading"]  - state key set to true/false
 * @param {string}   [opts.dataKey]               - state key that receives action.payload (omit to skip)
 * @param {string}   [opts.errorKey="error"]      - state key that receives the error
 * @param {Function} [opts.onFulfilled]           - optional (state, action) => void for custom fulfilled logic
 */
export const addAsyncCases = (
  builder,
  thunk,
  {
    loadingKey = "loading",
    dataKey,
    errorKey = "error",
    onFulfilled,
  } = {}
) => {
  builder
    .addCase(thunk.pending, (state) => {
      state[loadingKey] = true;
      state[errorKey] = null;
    })
    .addCase(thunk.fulfilled, (state, action) => {
      state[loadingKey] = false;
      if (onFulfilled) {
        onFulfilled(state, action);
      } else if (dataKey) {
        state[dataKey] = action.payload?.data ?? action.payload;
      }
    })
    .addCase(thunk.rejected, (state, action) => {
      state[loadingKey] = false;
      state[errorKey] = action.payload;
    });
};
