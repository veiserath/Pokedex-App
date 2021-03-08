//
//  TableViewController.swift
//  PokemonApp
//
//  Created by Kacper Młodkowski on 19/01/2021.
//

import UIKit
import Alamofire

class TableViewController: UITableViewController {
    
    
    var pokemons = [Pokemon]()
    var selectedPokemon: Pokemon? = nil
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        downloadPokemons()
    }
    
    func downloadPokemons() {
        AF.request("https://pokeapi.co/api/v2/pokemon?limit=151").responseJSON { response in
            if let error = response.error {
                self.presentError(error)
            }
            if let data = response.data {
                do {
                    self.pokemons = try JSONDecoder().decode(Pokemons.self, from: data).results
                    self.tableView.reloadData()
                }
                catch {
                    self.presentError(error)
                }
            }
        }
    }
    
    func presentError(_ error: Error) {
        let alert = UIAlertController(title: "Error occured", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Close", style: .cancel))
        alert.addAction(UIAlertAction(title: "Reload", style: .default) {_ in self.downloadPokemons()})
        self.present(alert,animated: true,completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pokemons.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PokemonCell", for: indexPath) as! PokemonTableViewCell
        cell.nameLabel.text = String(pokemons[indexPath.row].name.replacingOccurrences(of: "-", with: " "))
        cell.idLabel.text = "id: " + getIdFromURL(from: pokemons[indexPath.row].url)
        return cell
    }
    
    func getIdFromURL(from: String) -> String {
        var occurence = 0
        var parsedID = ""
        for char in from {
            
            if char == "/" {
                occurence += 1
            }
            if char != "/" && occurence == 6 {
                parsedID.append(char)
            }
            if char == "/" && occurence == 7 {
                return parsedID
            }
        }
        return from
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPokemon = pokemons[indexPath.row]
        performSegue(withIdentifier: "ShowPokemon", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowPokemon" {
            let viewController = segue.destination as! DetailViewController
            viewController.pokemon = selectedPokemon
        }
    }
}

class PokemonTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
}
