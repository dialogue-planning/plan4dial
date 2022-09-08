(define
    (domain day-planner)
    (:requirements :strips :typing)
    (:types )
    (:constants )
    (:predicates
        (have_cuisine)
        (have_restaurant)
        (have_have_allergy)
        (have_allergy)
        (have_food_restriction)
        (have_conflict)
        (conflict)
        (have_low_budget)
        (low_budget)
        (have_outing_atmosphere)
        (goal)
        (have-message)
        (force-statement)
        (cuisine-value-mexican)
        (cuisine-value-italian)
        (cuisine-value-chinese)
        (cuisine-value-dessert)
    )
    (:action get-cuisine
        :parameters()
        :precondition
            (and
                (not (have_cuisine))
                (not (force-statement))
            )
        :effect
            (labeled-oneof set-cuisine
                (outcome valid
                    (and
                        (have_cuisine)
                    )
                )
                (outcome fallback
                    (and
                        (have-message)
                        (force-statement)
                    )
                )
            )
    )
    (:action get-have-allergy
        :parameters()
        :precondition
            (and
                (not (have_have_allergy))
                (not (force-statement))
            )
        :effect
            (labeled-oneof set-allergy
                (outcome indicate_allergy
                    (and
                        (have_allergy)
                        (have_have_allergy)
                    )
                )
                (outcome indicate_no_allergy
                    (and
                        (not (have_allergy))
                        (have_conflict)
                        (not (conflict))
                        (have_have_allergy)
                    )
                )
                (outcome fallback
                    (and
                        (have-message)
                        (force-statement)
                    )
                )
            )
    )
    (:action get-allergy
        :parameters()
        :precondition
            (and
                (have_allergy)
                (not (force-statement))
            )
        :effect
            (labeled-oneof set-allergy
                (outcome update_allergy
                    (and
                        (have_food_restriction)
                    )
                )
                (outcome fallback
                    (and
                        (have-message)
                        (force-statement)
                    )
                )
            )
    )
    (:action reset-preferences
        :parameters()
        :precondition
            (and
                (conflict)
                (not (force-statement))
            )
        :effect
            (labeled-oneof reset
                (outcome reset-values
                    (and
                        (not (have_cuisine))
                        (not (have_food_restriction))
                        (not (have_have_allergy))
                    )
                )
            )
    )
    (:action dialogue_statement
        :parameters()
        :precondition
            (and
                (have-message)
                (force-statement)
            )
        :effect
            (labeled-oneof reset
                (outcome lock
                    (and
                        (not (have-message))
                        (not (force-statement))
                    )
                )
            )
    )
    (:action check-allergies-1-or-1
        :parameters()
        :precondition
            (and
                (have_allergy)
                (cuisine-value-mexican)
                (not (force-statement))
                (have_food_restriction)
            )
        :effect
            (labeled-oneof check-conflicts
                (outcome validate-combos
                    (and
                        (have_conflict)
                        (conflict)
                    )
                )
            )
    )
    (:action check-allergies-1-or-2
        :parameters()
        :precondition
            (and
                (have_allergy)
                (cuisine-value-italian)
                (not (force-statement))
                (have_food_restriction)
            )
        :effect
            (labeled-oneof check-conflicts
                (outcome validate-combos
                    (and
                        (have_conflict)
                        (conflict)
                    )
                )
            )
    )
    (:action set-restaurant-mexican-or-1
        :parameters()
        :precondition
            (and
                (not (conflict))
                (not (force-statement))
                (have_conflict)
                (cuisine-value-mexican)
                (have_cuisine)
            )
        :effect
            (labeled-oneof set
                (outcome valid
                    (and
                        (have_restaurant)
                    )
                )
                (outcome fallback
                    (and
                        (have-message)
                        (force-statement)
                    )
                )
            )
    )
    (:action set-restaurant-mexican-or-2
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (not (have_allergy))
                (cuisine-value-mexican)
                (have_cuisine)
                (have_have_allergy)
            )
        :effect
            (labeled-oneof set
                (outcome valid
                    (and
                        (have_restaurant)
                    )
                )
                (outcome fallback
                    (and
                        (have-message)
                        (force-statement)
                    )
                )
            )
    )
    (:action set-restaurant-italian-or-1
        :parameters()
        :precondition
            (and
                (not (conflict))
                (cuisine-value-italian)
                (not (force-statement))
                (have_conflict)
                (have_cuisine)
            )
        :effect
            (labeled-oneof set
                (outcome valid
                    (and
                        (have_restaurant)
                    )
                )
                (outcome fallback
                    (and
                        (have-message)
                        (force-statement)
                    )
                )
            )
    )
    (:action set-restaurant-italian-or-2
        :parameters()
        :precondition
            (and
                (cuisine-value-italian)
                (not (force-statement))
                (not (have_allergy))
                (have_cuisine)
                (have_have_allergy)
            )
        :effect
            (labeled-oneof set
                (outcome valid
                    (and
                        (have_restaurant)
                    )
                )
                (outcome fallback
                    (and
                        (have-message)
                        (force-statement)
                    )
                )
            )
    )
    (:action set-restaurant-chinese-or-1
        :parameters()
        :precondition
            (and
                (not (conflict))
                (cuisine-value-chinese)
                (not (force-statement))
                (have_conflict)
                (have_cuisine)
            )
        :effect
            (labeled-oneof set
                (outcome valid
                    (and
                        (have_restaurant)
                    )
                )
                (outcome fallback
                    (and
                        (have-message)
                        (force-statement)
                    )
                )
            )
    )
    (:action set-restaurant-chinese-or-2
        :parameters()
        :precondition
            (and
                (cuisine-value-chinese)
                (not (force-statement))
                (not (have_allergy))
                (have_cuisine)
                (have_have_allergy)
            )
        :effect
            (labeled-oneof set
                (outcome valid
                    (and
                        (have_restaurant)
                    )
                )
                (outcome fallback
                    (and
                        (have-message)
                        (force-statement)
                    )
                )
            )
    )
    (:action set-restaurant-dessert-or-1
        :parameters()
        :precondition
            (and
                (not (conflict))
                (cuisine-value-dessert)
                (not (force-statement))
                (have_conflict)
                (have_cuisine)
            )
        :effect
            (labeled-oneof set
                (outcome valid
                    (and
                        (have_restaurant)
                    )
                )
                (outcome fallback
                    (and
                        (have-message)
                        (force-statement)
                    )
                )
            )
    )
    (:action set-restaurant-dessert-or-2
        :parameters()
        :precondition
            (and
                (not (conflict))
                (not (have_allergy))
                (cuisine-value-dessert)
                (not (force-statement))
                (have_conflict)
                (have_cuisine)
                (have_have_allergy)
            )
        :effect
            (labeled-oneof set
                (outcome valid
                    (and
                        (have_restaurant)
                    )
                )
                (outcome fallback
                    (and
                        (have-message)
                        (force-statement)
                    )
                )
            )
    )
    (:action complete-or-1
        :parameters()
        :precondition
            (and
                (have_restaurant)
                (not (force-statement))
            )
        :effect
            (labeled-oneof finish
                (outcome finish
                    (and
                        (goal)
                    )
                )
            )
    )
    (:action complete-or-2
        :parameters()
        :precondition
            (and
                (conflict)
                (not (force-statement))
            )
        :effect
            (labeled-oneof finish
                (outcome finish
                    (and
                        (goal)
                    )
                )
            )
    )
    (:action reset-cuisine-value-mexican
        :parameters()
        :precondition
            (and
                (not (have_cuisine))
                (cuisine-value-mexican)
            )
        :effect
            (labeled-oneof reset
                (outcome reset-mexican
                    (and
                        (not (cuisine-value-mexican))
                    )
                )
            )
    )
    (:action reset-cuisine-value-italian
        :parameters()
        :precondition
            (and
                (not (have_cuisine))
                (cuisine-value-italian)
            )
        :effect
            (labeled-oneof reset
                (outcome reset-italian
                    (and
                        (not (cuisine-value-italian))
                    )
                )
            )
    )
    (:action reset-cuisine-value-chinese
        :parameters()
        :precondition
            (and
                (not (have_cuisine))
                (cuisine-value-chinese)
            )
        :effect
            (labeled-oneof reset
                (outcome reset-chinese
                    (and
                        (not (cuisine-value-chinese))
                    )
                )
            )
    )
    (:action reset-cuisine-value-dessert
        :parameters()
        :precondition
            (and
                (not (have_cuisine))
                (cuisine-value-dessert)
            )
        :effect
            (labeled-oneof reset
                (outcome reset-dessert
                    (and
                        (not (cuisine-value-dessert))
                    )
                )
            )
    )
    (:action set-cuisine
        :parameters()
        :precondition
            (and
                (not (cuisine-value-mexican))
                (not (cuisine-value-dessert))
                (have_cuisine)
                (not (cuisine-value-chinese))
                (not (cuisine-value-italian))
            )
        :effect
            (labeled-oneof set-valid-value
                (outcome mexican
                    (and
                        (cuisine-value-mexican)
                    )
                )
                (outcome italian
                    (and
                        (cuisine-value-italian)
                    )
                )
                (outcome chinese
                    (and
                        (cuisine-value-chinese)
                    )
                )
                (outcome dessert
                    (and
                        (cuisine-value-dessert)
                    )
                )
            )
    )
)