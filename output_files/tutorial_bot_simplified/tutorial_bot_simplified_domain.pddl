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
        (have_goal)
        (goal)
        (have-message)
        (force-statement)
        (food_restriction-value-dairy-free)
        (food_restriction-value-gluten-free)
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
                (not (force-statement))
                (not (have_have_allergy))
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
                        (have_conflict)
                        (not (conflict))
                        (have_have_allergy)
                        (not (have_allergy))
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
                (have_have_allergy)
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
                (have_conflict)
                (conflict)
                (not (force-statement))
            )
        :effect
            (labeled-oneof reset
                (outcome reset-values
                    (and
                        (not (cuisine-value-chinese))
                        (not (have_have_allergy))
                        (not (have_conflict))
                        (force-statement)
                        (not (have_cuisine))
                        (have-message)
                        (not (cuisine-value-mexican))
                        (not (have_food_restriction))
                        (not (food_restriction-value-dairy-free))
                        (not (food_restriction-value-gluten-free))
                        (not (cuisine-value-dessert))
                        (not (cuisine-value-italian))
                    )
                )
            )
    )
    (:action set-restaurant
        :parameters()
        :precondition
            (and
                (have_conflict)
                (not (have_restaurant))
                (not (conflict))
                (have_cuisine)
                (not (force-statement))
            )
        :effect
            (labeled-oneof assign_restaurant
                (outcome set-mexican
                    (and
                        (have_restaurant)
                    )
                )
                (outcome set-italian
                    (and
                        (have_restaurant)
                    )
                )
                (outcome set-chinese
                    (and
                        (have_restaurant)
                    )
                )
                (outcome set-dessert
                    (and
                        (have_restaurant)
                    )
                )
            )
    )
    (:action complete
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
                        (have_goal)
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
                (food_restriction-value-gluten-free)
                (have_allergy)
                (have_have_allergy)
                (cuisine-value-mexican)
                (not (force-statement))
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
    (:action check-conflict-1-or-2
        :parameters()
        :precondition
            (and
                (have_allergy)
                (cuisine-value-dessert)
                (have_have_allergy)
                (food_restriction-value-dairy-free)
                (not (force-statement))
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
    (:action check-conflict-2-or-1
        :parameters()
        :precondition
            (and
                (have_allergy)
                (have_food_restriction)
                (have_have_allergy)
                (cuisine-value-italian)
                (not (force-statement))
            )
        :effect
            (labeled-oneof check-conflicts
                (outcome validate-combos
                    (and
                        (have_conflict)
                        (not (conflict))
                    )
                )
            )
    )
    (:action check-conflict-2-or-2
        :parameters()
        :precondition
            (and
                (have_allergy)
                (have_food_restriction)
                (have_have_allergy)
                (not (force-statement))
                (cuisine-value-chinese)
            )
        :effect
            (labeled-oneof check-conflicts
                (outcome validate-combos
                    (and
                        (have_conflict)
                        (not (conflict))
                    )
                )
            )
    )
    (:action check-conflict-2-or-3
        :parameters()
        :precondition
            (and
                (have_allergy)
                (have_have_allergy)
                (cuisine-value-mexican)
                (food_restriction-value-dairy-free)
                (not (force-statement))
            )
        :effect
            (labeled-oneof check-conflicts
                (outcome validate-combos
                    (and
                        (have_conflict)
                        (not (conflict))
                    )
                )
            )
    )
    (:action check-conflict-2-or-4
        :parameters()
        :precondition
            (and
                (food_restriction-value-gluten-free)
                (have_allergy)
                (cuisine-value-dessert)
                (have_have_allergy)
                (not (force-statement))
            )
        :effect
            (labeled-oneof check-conflicts
                (outcome validate-combos
                    (and
                        (have_conflict)
                        (not (conflict))
                    )
                )
            )
    )
    (:action set-food_restriction
        :parameters()
        :precondition
            (and
                (not (food_restriction-value-gluten-free))
                (have_food_restriction)
                (not (food_restriction-value-dairy-free))
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
    (:action set-cuisine
        :parameters()
        :precondition
            (and
                (not (cuisine-value-chinese))
                (not (cuisine-value-mexican))
                (not (cuisine-value-dessert))
                (have_cuisine)
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