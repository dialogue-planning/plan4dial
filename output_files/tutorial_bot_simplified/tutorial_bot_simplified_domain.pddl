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
        (checked-for-conflict)
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
        (food_restriction-value-dairy-free)
        (food_restriction-value-gluten-free)
    )
    (:action get-cuisine
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (not (have_cuisine))
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
                (not (force-statement))
                (not (have_have_allergy))
            )
        :effect
            (labeled-oneof set-allergy
                (outcome indicate_allergy
                    (and
                        (have_have_allergy)
                        (have_allergy)
                    )
                )
                (outcome indicate_no_allergy
                    (and
                        (have_conflict)
                        (not (have_allergy))
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
                (not (force-statement))
                (have_have_allergy)
                (have_allergy)
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
                (have_conflict)
            )
        :effect
            (labeled-oneof reset
                (outcome reset-values
                    (and
                        (not (conflict))
                        (not (have_cuisine))
                        (not (have_conflict))
                        (not (have_have_allergy))
                        (not (have_food_restriction))
                    )
                )
            )
    )
    (:action set-restaurant-mexican
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (cuisine-value-mexican)
                (not (conflict))
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
    (:action set-restaurant-italian
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (cuisine-value-italian)
                (not (conflict))
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
    (:action set-restaurant-chinese
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (not (conflict))
                (cuisine-value-chinese)
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
    (:action set-restaurant-dessert
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (not (conflict))
                (have_conflict)
                (have_cuisine)
                (cuisine-value-dessert)
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
    (:action complete
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (have_restaurant)
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
                        (not (force-statement))
                        (not (have-message))
                    )
                )
            )
    )
    (:action check-conflict-1-or-1
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (cuisine-value-mexican)
                (have_have_allergy)
                (food_restriction-value-gluten-free)
                (have_allergy)
            )
        :effect
            (labeled-oneof check-conflicts
                (outcome validate-combos
                    (and
                        (conflict)
                        (have_conflict)
                    )
                )
            )
    )
    (:action check-conflict-1-or-2
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (have_have_allergy)
                (food_restriction-value-dairy-free)
                (have_allergy)
                (cuisine-value-dessert)
            )
        :effect
            (labeled-oneof check-conflicts
                (outcome validate-combos
                    (and
                        (conflict)
                        (have_conflict)
                    )
                )
            )
    )
    (:action check-conflict-2-or-1
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (have_have_allergy)
                (cuisine-value-italian)
                (have_allergy)
                (have_food_restriction)
            )
        :effect
            (labeled-oneof check-conflicts
                (outcome validate-combos
                    (and
                        (not (conflict))
                        (have_conflict)
                    )
                )
            )
    )
    (:action check-conflict-2-or-2
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (have_have_allergy)
                (cuisine-value-chinese)
                (have_allergy)
                (have_food_restriction)
            )
        :effect
            (labeled-oneof check-conflicts
                (outcome validate-combos
                    (and
                        (not (conflict))
                        (have_conflict)
                    )
                )
            )
    )
    (:action check-conflict-2-or-3
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (cuisine-value-mexican)
                (have_have_allergy)
                (food_restriction-value-dairy-free)
                (have_allergy)
            )
        :effect
            (labeled-oneof check-conflicts
                (outcome validate-combos
                    (and
                        (not (conflict))
                        (have_conflict)
                    )
                )
            )
    )
    (:action check-conflict-2-or-4
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (have_have_allergy)
                (food_restriction-value-gluten-free)
                (have_allergy)
                (cuisine-value-dessert)
            )
        :effect
            (labeled-oneof check-conflicts
                (outcome validate-combos
                    (and
                        (not (conflict))
                        (have_conflict)
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
                (not (cuisine-value-chinese))
                (not (cuisine-value-italian))
                (not (cuisine-value-dessert))
                (have_cuisine)
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
    (:action reset-food_restriction-value-dairy-free
        :parameters()
        :precondition
            (and
                (food_restriction-value-dairy-free)
                (not (have_food_restriction))
            )
        :effect
            (labeled-oneof reset
                (outcome reset-dairy-free
                    (and
                        (not (food_restriction-value-dairy-free))
                    )
                )
            )
    )
    (:action reset-food_restriction-value-gluten-free
        :parameters()
        :precondition
            (and
                (food_restriction-value-gluten-free)
                (not (have_food_restriction))
            )
        :effect
            (labeled-oneof reset
                (outcome reset-gluten-free
                    (and
                        (not (food_restriction-value-gluten-free))
                    )
                )
            )
    )
    (:action set-food_restriction
        :parameters()
        :precondition
            (and
                (not (food_restriction-value-gluten-free))
                (not (food_restriction-value-dairy-free))
                (have_food_restriction)
            )
        :effect
            (labeled-oneof set-valid-value
                (outcome dairy-free
                    (and
                        (food_restriction-value-dairy-free)
                    )
                )
                (outcome gluten-free
                    (and
                        (food_restriction-value-gluten-free)
                    )
                )
            )
    )
)