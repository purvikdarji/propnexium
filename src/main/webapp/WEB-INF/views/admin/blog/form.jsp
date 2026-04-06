<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${empty post.id ? 'Create' : 'Edit'} Blog Post | Admin Mode</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <!-- Quill.js CDN -->
    <link href="https://cdn.quilljs.com/1.3.6/quill.snow.css" rel="stylesheet">
    <script src="https://cdn.quilljs.com/1.3.6/quill.min.js"></script>
    <style>
        body { font-family: 'Inter', sans-serif; background: #f1f5f9; color: #1e293b; margin: 0; padding: 0; }
        .wrapper { display: flex; height: 100vh; overflow: hidden; }
        .main-content { flex: 1; overflow-y: auto; padding: 40px; }
        
        .header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px; }
        .header h1 { font-size: 24px; margin: 0; font-weight: 700; color: #0f172a; }
        
        .editor-card { background: white; border-radius: 12px; padding: 30px; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05); }
        
        .form-group { margin-bottom: 24px; }
        .form-group label { display: block; font-size: 14px; font-weight: 600; margin-bottom: 8px; color: #334155; }
        .form-control { width: 100%; padding: 12px 16px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 14px; color: #1e293b; box-sizing: border-box; }
        .form-control:focus { border-color: #3b82f6; outline: none; box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1); }
        
        select.form-control { appearance: none; background: #fff url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 24 24' fill='none' stroke='%2364748b' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpolyline points='6 9 12 15 18 9'%3E%3C/polyline%3E%3C/svg%3E") no-repeat right 16px center; }
        
        textarea.form-control { resize: vertical; font-family: inherit; }
        #quill-editor { height: 400px; border-bottom-left-radius: 8px; border-bottom-right-radius: 8px; font-family: 'Inter', sans-serif; font-size: 16px; }
        .ql-toolbar { border-top-left-radius: 8px; border-top-right-radius: 8px; background: #f8fafc; }
        .char-counter { font-size: 12px; color: #64748b; margin-top: 6px; text-align: right; }
        
        .btn-group { display: flex; gap: 12px; margin-top: 30px; }
        .btn { padding: 12px 24px; border-radius: 8px; font-weight: 600; font-size: 14px; cursor: pointer; border: none; transition: all 0.2s; }
        .btn-draft { background: #f1f5f9; color: #475569; border: 1px solid #cbd5e1; }
        .btn-draft:hover { background: #e2e8f0; }
        .btn-publish { background: #2563eb; color: white; }
        .btn-publish:hover { background: #1d4ed8; }
        
        .cancel-link { align-self: center; color: #64748b; text-decoration: none; font-size: 14px; font-weight: 500; margin-left: 12px; }
        .cancel-link:hover { color: #0f172a; text-decoration: underline; }
        
        /* New Image Upload Styles */
        .image-upload-container { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; background: #f8fafc; padding: 20px; border-radius: 10px; border: 1.5px dashed #cbd5e1; margin-bottom: 24px; }
        .upload-option { display: flex; flex-direction: column; gap: 8px; }
        .preview-area { width: 100%; height: 180px; background: #fff; border-radius: 8px; border: 1px solid #e2e8f0; display: flex; align-items: center; justify-content: center; overflow: hidden; position: relative; margin-top: 10px; }
        .preview-area img { max-width: 100%; max-height: 100%; object-fit: cover; }
        .preview-placeholder { color: #94a3b8; font-size: 12px; display: flex; flex-direction: column; align-items: center; gap: 8px; }
    </style>
</head>
<body>
    <div class="wrapper">
        <div class="main-content">
            <div class="header">
                <h1>${empty post.id ? 'Write new post' : 'Edit Post'}</h1>
            </div>
            
            <div class="editor-card">
                <form:form action="${empty post.id ? '/admin/blog/new' : '/admin/blog/' += post.id += '/edit'}" 
                           method="POST" modelAttribute="post" enctype="multipart/form-data">
                    
                    <div class="form-group">
                        <label for="title">Title *</label>
                        <form:input path="title" id="title" class="form-control" required="true" placeholder="Enter an engaging title"/>
                    </div>
                    
                    <div style="display: flex; gap: 20px;">
                        <div class="form-group" style="flex: 1;">
                            <label for="category">Category *</label>
                            <form:select path="category" id="category" class="form-control" required="true">
                                <form:option value="">Select Category...</form:option>
                                <form:option value="Buying Guide">Buying Guide</form:option>
                                <form:option value="Market Trends">Market Trends</form:option>
                                <form:option value="Legal Tips">Legal Tips</form:option>
                                <form:option value="Investment">Investment</form:option>
                                <form:option value="Renting Tips">Renting Tips</form:option>
                                <form:option value="Interior Design">Interior Design</form:option>
                            </form:select>
                        </div>
                        
                        <div class="form-group" style="flex: 1;">
                            <label for="tags">Tags</label>
                            <form:input path="tags" id="tags" class="form-control" placeholder="Comma-separated: EMI, first home, Mumbai"/>
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label>Cover Image (Required)</label>
                        <div class="image-upload-container">
                            <div class="upload-option">
                                <label for="coverImageFile" style="color: #64748b; font-size: 13px;">Option 1: Upload from Device</label>
                                <input type="file" name="coverImageFile" id="coverImageFile" class="form-control" accept="image/*" onchange="previewFile(this)">
                                
                                <label for="coverImage" style="color: #64748b; font-size: 13px; margin-top: 15px;">Option 2: External Image URL</label>
                                <form:input path="coverImage" id="coverImage" class="form-control" placeholder="https://..." oninput="previewUrl(this.value)"/>
                            </div>
                            <div class="upload-option">
                                <label style="color: #64748b; font-size: 13px;">Image Preview</label>
                                <div class="preview-area" id="imagePreviewContainer">
                                    <c:choose>
                                        <c:when test="${not empty post.coverImage}">
                                            <img src="${post.coverImage}" id="imagePreview" alt="Preview">
                                        </c:when>
                                        <c:otherwise>
                                            <div class="preview-placeholder" id="previewPlaceholder">
                                                <span style="font-size: 24px;">🖼️</span>
                                                <span>No image selected</span>
                                            </div>
                                            <img id="imagePreview" style="display: none;">
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label for="excerpt">Excerpt / Summary *</label>
                        <form:textarea path="excerpt" id="excerpt" class="form-control" rows="3" maxlength="200" required="true" 
                                       onkeyup="document.getElementById('charCount').innerText = this.value.length;"
                                       placeholder="Short description for listing cards..." />
                        <div class="char-counter"><span id="charCount">${empty post.excerpt ? 0 : post.excerpt.length()}</span> / 200 characters</div>
                    </div>
                    
                    <div class="form-group">
                        <label for="content">Article Content *</label>
                        <!-- Hidden textarea for form submission -->
                        <form:textarea path="content" id="content" style="display:none;" />
                        <!-- Quill Editor Container -->
                        <div id="quill-editor">${post.content}</div>
                    </div>
                    
                    <div class="btn-group">
                        <button type="submit" name="action" value="draft" class="btn btn-draft">Save as Draft</button>
                        <button type="submit" name="action" value="publish" class="btn btn-publish">Publish Post</button>
                        <a href="/admin/blog" class="cancel-link">Cancel</a>
                    </div>
                </form:form>
            </div>
        </div>
    </div>

    <script>
        // Quill.js Initialization
        var quill = new Quill('#quill-editor', {
            theme: 'snow',
            placeholder: 'Start writing your amazing article here...',
            modules: {
                toolbar: [
                    [{ 'header': [1, 2, 3, false] }],
                    ['bold', 'italic', 'underline', 'strike'],
                    ['blockquote', 'code-block'],
                    [{ 'list': 'ordered'}, { 'list': 'bullet' }],
                    [{ 'color': [] }, { 'background': [] }],
                    ['link', 'image'],
                    ['clean']
                ]
            }
        });

        // Sync Quill content to hidden textarea before form submission
        const form = document.querySelector('form');
        form.onsubmit = function() {
            const content = document.querySelector('#content');
            content.value = quill.root.innerHTML;
        };

        function previewFile(input) {
            const preview = document.getElementById('imagePreview');
            const placeholder = document.getElementById('previewPlaceholder');
            
            if (input.files && input.files[0]) {
                const reader = new FileReader();
                reader.onload = function(e) {
                    preview.src = e.target.result;
                    preview.style.display = 'block';
                    if (placeholder) placeholder.style.display = 'none';
                }
                reader.readAsDataURL(input.files[0]);
            }
        }

        function previewUrl(url) {
            const preview = document.getElementById('imagePreview');
            const placeholder = document.getElementById('previewPlaceholder');
            
            if (url && url.trim().length > 0) {
                preview.src = url;
                preview.style.display = 'block';
                if (placeholder) placeholder.style.display = 'none';
                
                // Clear file input if URL is entered
                document.getElementById('coverImageFile').value = '';
            } else if (!document.getElementById('coverImageFile').value) {
                preview.style.display = 'none';
                if (placeholder) placeholder.style.display = 'flex';
            }
        }
    </script>
</body>
</html>
