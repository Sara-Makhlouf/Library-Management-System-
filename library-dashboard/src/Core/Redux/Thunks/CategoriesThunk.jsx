import api from "../../Api/aixos";
import { createApiThunk } from "../utils/reduxHelpers";

export const getCategory = createApiThunk(
  "category/getcategory",
  async () => {
    const response = await api.get("/categories");
    return response.data;
  }
);

export const createCategory = createApiThunk(
  "category/createcategory",
  async (categoryData) => {
    const response = await api.post("/categories", categoryData);
    return response.data;
  }
);
