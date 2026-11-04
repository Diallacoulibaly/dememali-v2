package com.example.dememalibackend.repository;
import com.example.dememalibackend.entity.Utilisateur;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;


public interface UtilisateurRepository extends  JpaRepository<Utilisateur,Integer> {
    Optional<Utilisateur> findByTelephone(String telephone);
    boolean existsByTelephoneAndIdNot(String telephone, Integer id);

    boolean existsByTelephone(String telephone);


}



