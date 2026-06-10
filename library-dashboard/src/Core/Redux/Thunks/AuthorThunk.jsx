import api from "../../Api/aixos";
import { createApiThunk } from "../utils/reduxHelpers";

export const getauthor = createApiThunk(
  "author/getauthor",
  async (authorId) => {
    const response = await api.get(`/authors/${authorId}`);
    return response.data;
  }
);
