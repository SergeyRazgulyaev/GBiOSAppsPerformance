//
//  NetworkService.swift
//  VKClient_RazgulyaevSergey
//
//  Created by Sergey Razgulyaev on 12.08.2020.
//  Copyright © 2020 Sergey Razgulyaev. All rights reserved.
//

import Foundation
import Alamofire
import RealmSwift

class NetworkService {
    
    //MARK: - Properties for Interaction with Network
    private let baseUrl: String = "https://api.vk.com"
    private let apiVersion: String = "5.124"
    
    static let sessionAF: Alamofire.Session = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 20
        let session = Alamofire.Session(configuration: configuration)
        return session
    }()
    
    enum AlbumID: String {
        case wall = "wall"
        case profile = "profile"
        case saved = "saved"
    }
    
    enum typeOfNews: String {
        case post = "post"
        case photo = "photo,wall_photo"
    }
    
    //MARK: - Function to download Friends information
    func loadFriends(token: String, completion: ((Result<[UserItems], Error>) -> Void)? = nil) {
        let path = "/method/friends.get"
        
        let params: Parameters = [
            "access_token": token,
            "order": "name",
            "fields": ["nickname", "sex", "bdate", "city", "photo_100"],
            "v": apiVersion
        ]
        
        NetworkService.sessionAF.request(baseUrl + path, method: .get, parameters: params).responseData { response in
            guard let data = response.value else { return }
            
            do {
                guard let friends = try JSONDecoder().decode(User.self, from: data).response?.items else { return }
                completion?(.success(friends))
            } catch {
                print(error.localizedDescription)
                completion?(.failure(error))
            }
        }.resume()
    }
    
    //MARK: - Function to download Photos information
    func loadPhotos(token: String, ownerID: Int, albumID: AlbumID, photoCount: Int, completion: ((Result<[PhotoItems], Error>) -> Void)? = nil) {
        let path = "/method/photos.get"
        
        let params: Parameters = [
            "access_token": token,
            "owner_id": ownerID,
            "album_id": albumID.rawValue,
            "rev": 1,
            "extended": 1,
            "v": apiVersion
        ]
        
        NetworkService.sessionAF.request(baseUrl + path, method: .get, parameters: params).responseData { response in
            guard let data = response.value else { return }
            
            do {
                guard let photos = try JSONDecoder().decode(Photo.self, from: data).response?.items else { return }
                completion?(.success(photos))
            } catch {
                print(error.localizedDescription)
                completion?(.failure(error))
            }
        }.resume()
    }
    
    //MARK: - Function to download Groups information
    func loadGroups(token: String, completion: ((Result<[GroupItems], Error>) -> Void)? = nil) {
        let path = "/method/groups.get"
        
        let params: Parameters = [
            "access_token": token,
            "extended": 1,
            "v": apiVersion
        ]
        
        NetworkService.sessionAF.request(baseUrl + path, method: .get, parameters: params).responseData { response in
            guard let data = response.value else { return }
            
            do {
                guard let groups = try JSONDecoder().decode(Group.self, from: data).response?.items else { return }
                completion?(.success(groups))
            } catch {
                print(error.localizedDescription)
                completion?(.failure(error))
            }
        }.resume()
    }
    
    //MARK: - Function to download News information
    func loadNews(token: String, typeOfNews: typeOfNews, completion: ((Result<NewsResponse, Error>) -> Void)? = nil) {
        let path = "/method/newsfeed.get"
        
        let params: Parameters = [
            "access_token": token,
            "filters": typeOfNews,
            "source_ids": "groups",
            "count": 10,
            "v": apiVersion
        ]
        
        NetworkService.sessionAF.request(baseUrl + path, method: .get, parameters: params).responseData(queue: .global(qos: .utility)) { response in
            guard let data = response.value else { return }
            
            var newsItems = List<NewsItems>()
            var newsProfiles = List<NewsProfiles>()
            var newsGroups = List<NewsGroups>()
            
            let parsedNewsElementsDispatchGroup = DispatchGroup()
            
            DispatchQueue.global().async(group: parsedNewsElementsDispatchGroup) {
                newsItems = try! JSONDecoder().decode(News.self, from: data).response?.items ?? List<NewsItems>()
            }
            DispatchQueue.global().async(group: parsedNewsElementsDispatchGroup) {
                newsProfiles = try! JSONDecoder().decode(News.self, from: data).response?.profiles ??  List<NewsProfiles>()
            }
            DispatchQueue.global().async(group: parsedNewsElementsDispatchGroup) {
                newsGroups = try! JSONDecoder().decode(News.self, from: data).response?.groups ?? List<NewsGroups>()
            }
            
            parsedNewsElementsDispatchGroup.notify(queue: DispatchQueue.main) {
                let news = NewsResponse(items: newsItems, profiles: newsProfiles, groups: newsGroups, newsResponseNewOffset: "", nextFrom: "")
                completion?(.success(news))
            }
        }
    }
    
    //MARK: - Function to download Searched Groups information
    func loadSearchedGroups(token: String, searchedGroupName: String, completion: ((Result<[GroupItems], Error>) -> Void)? = nil) {
        let path = "/method/groups.get"
        
        let params: Parameters = [
            "access_token": token,
            "q": searchedGroupName,
            "count": 15,
            "v": apiVersion
        ]
        
        NetworkService.sessionAF.request(baseUrl + path, method: .get, parameters: params).responseData { response in
            guard let data = response.value else { return }
            
            do {
                guard let groups = try JSONDecoder().decode(Group.self, from: data).response?.items else { return }
                completion?(.success(groups))
            } catch {
                print(error.localizedDescription)
                completion?(.failure(error))
            }
        }.resume()
    }
}
