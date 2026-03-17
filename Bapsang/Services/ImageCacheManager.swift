//
//  ImageCacheManager.swift
//  Bapsang
//

import SwiftUI

actor ImageCacheManager {
    static let shared = ImageCacheManager()

    // MARK: - Memory Cache (NSCache – auto-evicts on memory pressure)

    private let memoryCache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.countLimit = 80
        cache.totalCostLimit = 60 * 1024 * 1024 // 60 MB
        return cache
    }()

    // MARK: - Disk Cache

    private let diskCacheURL: URL = {
        let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let dir = caches.appendingPathComponent("ImageCache", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }()

    private let maxDiskBytes: Int = 100 * 1024 * 1024 // 100 MB

    // MARK: - Public API

    func image(for url: URL) async -> UIImage? {
        let key = cacheKey(for: url)

        // 1. Memory hit
        if let cached = memoryCache.object(forKey: key as NSString) {
            return cached
        }

        // 2. Disk hit
        if let diskImage = loadFromDisk(key: key) {
            memoryCache.setObject(diskImage, forKey: key as NSString, cost: diskImage.jpegData(compressionQuality: 1)?.count ?? 0)
            touchFile(key: key) // update access date for LRU
            return diskImage
        }

        // 3. Network download
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let downloaded = UIImage(data: data) else { return nil }
            memoryCache.setObject(downloaded, forKey: key as NSString, cost: data.count)
            saveToDisk(data: data, key: key)
            return downloaded
        } catch {
            return nil
        }
    }

    // MARK: - Disk helpers

    private func cacheKey(for url: URL) -> String {
        let hash = url.absoluteString.utf8.reduce(into: UInt64(5381)) { result, byte in
            result = 127 &* (result & 0x00FF_FFFF_FFFF_FFFF) &+ UInt64(byte)
        }
        return String(hash, radix: 36)
    }

    private func fileURL(key: String) -> URL {
        diskCacheURL.appendingPathComponent(key)
    }

    private func loadFromDisk(key: String) -> UIImage? {
        let url = fileURL(key: key)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }

    private func saveToDisk(data: Data, key: String) {
        let url = fileURL(key: key)
        try? data.write(to: url, options: .atomic)
        trimDiskCacheIfNeeded()
    }

    private func touchFile(key: String) {
        let url = fileURL(key: key)
        try? FileManager.default.setAttributes(
            [.modificationDate: Date()],
            ofItemAtPath: url.path
        )
    }

    private func trimDiskCacheIfNeeded() {
        let fm = FileManager.default
        guard let files = try? fm.contentsOfDirectory(
            at: diskCacheURL,
            includingPropertiesForKeys: [.contentModificationDateKey, .fileSizeKey]
        ) else { return }

        var totalSize = 0
        var fileInfos: [(url: URL, date: Date, size: Int)] = []

        for file in files {
            guard let values = try? file.resourceValues(forKeys: [.contentModificationDateKey, .fileSizeKey]),
                  let date = values.contentModificationDate,
                  let size = values.fileSize else { continue }
            totalSize += size
            fileInfos.append((file, date, size))
        }

        guard totalSize > maxDiskBytes else { return }

        // Sort oldest first (LRU eviction)
        fileInfos.sort { $0.date < $1.date }

        for info in fileInfos {
            try? fm.removeItem(at: info.url)
            totalSize -= info.size
            if totalSize <= maxDiskBytes { break }
        }
    }
}
