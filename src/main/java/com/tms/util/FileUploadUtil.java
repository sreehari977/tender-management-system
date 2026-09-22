package com.tms.util;

import jakarta.servlet.http.Part;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;
import java.util.UUID;

public class FileUploadUtil {

    private static final String BASE_UPLOAD_DIR;

    static {
        String configured = System.getProperty("tms.upload.dir", System.getenv("TMS_UPLOAD_DIR"));
        if (configured != null && !configured.trim().isEmpty()) {
            BASE_UPLOAD_DIR = configured.trim();
        } else {
            File projectUploads = new File("C:\\Users\\sreeh\\OneDrive\\Desktop\\JAVA PROJECT SETUP\\tms-uploads");
            if (projectUploads.exists()) {
                BASE_UPLOAD_DIR = projectUploads.getAbsolutePath();
            } else {
                BASE_UPLOAD_DIR = new File(System.getProperty("user.home"), "tms-uploads").getAbsolutePath();
            }
        }
    }

    private static final Set<String> ALLOWED_EXTENSIONS = new HashSet<>(Arrays.asList(
        "pdf", "doc", "docx", "zip", "png", "jpg", "jpeg", "txt", "xlsx", "csv"
    ));

    public static File getBaseDir(String subDir) {
        File dir = new File(BASE_UPLOAD_DIR, subDir);
        if (!dir.exists()) {
            dir.mkdirs();
        }
        return dir;
    }

    public static String saveUploadedFile(Part part, String subDir) throws IOException {
        if (part == null || part.getSize() <= 0) {
            return null;
        }

        String submittedFileName = part.getSubmittedFileName();
        if (submittedFileName == null || submittedFileName.trim().isEmpty()) {
            return null;
        }

        // Sanitize file name
        String rawName = new File(submittedFileName).getName();
        String extension = "";
        int dotIndex = rawName.lastIndexOf('.');
        if (dotIndex > 0 && dotIndex < rawName.length() - 1) {
            extension = rawName.substring(dotIndex + 1).toLowerCase();
        }

        if (!ALLOWED_EXTENSIONS.contains(extension)) {
            throw new IllegalArgumentException("Unsupported file type: " + extension +
                ". Allowed types: PDF, DOC, DOCX, ZIP, XLSX, CSV, images.");
        }

        // Generate unique safe file name
        String uniqueName = UUID.randomUUID().toString().substring(0, 8) + "_" + rawName.replaceAll("[^a-zA-Z0-9._-]", "_");
        File targetDir = getBaseDir(subDir);
        File destination = new File(targetDir, uniqueName);

        // Security: directory traversal check
        if (!destination.getCanonicalPath().startsWith(targetDir.getCanonicalPath())) {
            throw new SecurityException("Directory traversal attempt detected.");
        }

        try (InputStream in = part.getInputStream()) {
            Files.copy(in, destination.toPath(), StandardCopyOption.REPLACE_EXISTING);
        }

        return uniqueName;
    }

    public static File getFile(String subDir, String fileName) throws IOException {
        if (fileName == null || fileName.trim().isEmpty()) {
            return null;
        }
        File targetDir = getBaseDir(subDir);
        File file = new File(targetDir, fileName);
        if (!file.getCanonicalPath().startsWith(targetDir.getCanonicalPath())) {
            throw new SecurityException("Directory traversal attempt detected.");
        }
        return file.exists() ? file : null;
    }
}
