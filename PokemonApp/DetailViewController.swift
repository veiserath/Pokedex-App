//
//  ViewController.swift
//  PokemonApp
//
//  Created by Kacper Młodkowski on 19/01/2021.
//

import UIKit
import Alamofire
import SwiftyJSON

class DetailViewController: UIViewController {
    
    var pokemon: Pokemon? = nil
    
    @IBOutlet weak var pokemonImage: UIImageView!
    @IBOutlet weak var loadingScreen: UIActivityIndicatorView!
    @IBOutlet weak var pokemonAbilities: UILabel!
    @IBOutlet weak var pokemonHeight: UILabel!
    @IBOutlet weak var pokemonWeight: UILabel!
    @IBOutlet weak var pokemonBaseExperience: UILabel!
    @IBOutlet weak var pokemonNumber: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = pokemon?.name
        loadingScreen.startAnimating()
        loadingScreen.hidesWhenStopped = true
        downloadParameters()
    }
    
    func downloadParameters() {
        if let pokemon = pokemon {
            
            AF.request(pokemon.url).responseJSON { response in
                if let error = response.error {
                    self.presentError(error)
                }
                if let data = response.data {
                    do {
                        let json = try JSON(data: data)
                        self.getPokemonParameters(json: json)
                    }
                    catch {
                        self.presentError(error)
                    }
                }
            }
        } else {
            return
        }
    }
    
    
    func presentError(_ error: Error){
        let alert = UIAlertController(title: "Error occured", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Close", style: .cancel))
        alert.addAction(UIAlertAction(title: "Reload", style: .default) {_ in self.downloadParameters()})
        self.present(alert,animated: true,completion: nil)
    }
    
    
    func getPokemonParameters(json: JSON) {
        if let spriteUrl = json["sprites","front_default"].string{
            if let url = URL(string: spriteUrl) {
                self.downloadImage(from: url)
            }
        }
        
        let abilitiesJSON = json["abilities"]
        var abilities = ""
        for (_,subJson):(String, JSON) in abilitiesJSON {
            abilities += " "
            if let someAbility = subJson["ability"]["name"].string?.replacingOccurrences(of: "-", with: " ") {
                abilities += someAbility
            }
        }
        
        self.pokemonAbilities.text = abilities
        
        if let experience = json["base_experience"].int {
            self.pokemonBaseExperience.text = "\(experience)"
        }
        if let weight = json["weight"].int {
            self.pokemonWeight.text = "\(weight)"
        }
        if let height = json["height"].int {
            self.pokemonHeight.text = "\(height)"
        }
        if let id = json["id"].int {
            self.pokemonNumber.text = "\(id)"
        }
        loadingScreen.stopAnimating()
    }
    
    //    https://stackoverflow.com/questions/24231680/loading-downloading-image-from-url-on-swift
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    
    func downloadImage(from url: URL) {
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() { [weak self] in
                self?.pokemonImage.image = UIImage(data: data)
            }
        }
    }
}

