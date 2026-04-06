package com.propnexium.service;

import com.propnexium.entity.News;
import java.util.List;

public interface NewsService {
    List<News> getAllNews();
    News getNewsById(Long id);
    News createNews(News news);
    News updateNews(Long id, News newsDetails);
    void deleteNews(Long id);
}
