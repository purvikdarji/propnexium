package com.propnexium.service.impl;

import com.propnexium.entity.News;
import com.propnexium.repository.NewsRepository;
import com.propnexium.service.NewsService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@Transactional
public class NewsServiceImpl implements NewsService {

    @Autowired
    private NewsRepository newsRepository;

    @Override
    public List<News> getAllNews() {
        return newsRepository.findAllByOrderByCreatedAtDesc();
    }

    @Override
    public News getNewsById(Long id) {
        return newsRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("News article not found id: " + id));
    }

    @Override
    public News createNews(News news) {
        return newsRepository.save(news);
    }

    @Override
    public News updateNews(Long id, News newsDetails) {
        News existing = getNewsById(id);
        existing.setTitle(newsDetails.getTitle());
        existing.setContent(newsDetails.getContent());
        existing.setAuthor(newsDetails.getAuthor());
        return newsRepository.save(existing);
    }

    @Override
    public void deleteNews(Long id) {
        newsRepository.deleteById(id);
    }
}
