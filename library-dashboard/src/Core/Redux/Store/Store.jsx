import { configureStore } from "@reduxjs/toolkit";

import authReducer from "../Slice/AuthSlice";
import authorReducer from "./slices/authorSlice";
import categoryReducer from "./slices/categorySlice";
import bookReducer from "./slices/bookSlice";
import dashboardReducer from "./slices/dashboardSlice";
import waitingListReducer from "./slices/waitingListSlice";

export const store = configureStore({
  reducer: {
    auth: authReducer,
    authors: authorReducer,
    categories: categoryReducer,
    books: bookReducer,
    dashboard: dashboardReducer,
    waitingList: waitingListReducer,
  },
});