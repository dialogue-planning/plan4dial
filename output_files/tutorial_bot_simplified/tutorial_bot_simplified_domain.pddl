(define
    (domain day-planner)
    (:requirements :strips :typing)
    (:types )
    (:constants )
    (:predicates
        (have_cuisine)
        (maybe-have_cuisine)
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
                        (not (conflict))
                        (have_have_allergy)
                        (not (have_allergy))
                        (have_conflict)
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
                (have_allergy)
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
                (not (force-statement))
                (conflict)
                (have_conflict)
            )
        :effect
            (labeled-oneof reset
                (outcome reset-values
                    (and
                        (not (cuisine-value-dessert))
                        (not (cuisine-value-mexican))
                        (not (have_conflict))
                        (not (cuisine-value-chinese))
                        (not (have_food_restriction))
                        (not (have_have_allergy))
                        (not (maybe-have_cuisine))
                        (have-message)
                        (not (food_restriction-value-dairy-free))
                        (not (food_restriction-value-gluten-free))
                        (not (cuisine-value-italian))
                        (not (have_cuisine))
                        (force-statement)
                    )
                )
            )
    )
    (:action set-restaurant
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (not (have_restaurant))
                (have_conflict)
                (not (conflict))
                (not (maybe-have_cuisine))
                (have_cuisine)
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
                (not (force-statement))
                (have_restaurant)
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
    (:action slot-fill__get-cuisine
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (not (maybe-have_cuisine))
                (not (have_cuisine))
            )
        :effect
            (labeled-oneof validate-slot-fill
                (outcome cuisine_found
                    (and
                        (not (maybe-have_cuisine))
                        (have_cuisine)
                    )
                )
                (outcome cuisine_maybe-found
                    (and
                        (maybe-have_cuisine)
                        (not (have_cuisine))
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
    (:action clarify__cuisine
        :parameters()
        :precondition
            (and
                (maybe-have_cuisine)
                (not (have_cuisine))
                (not (force-statement))
            )
        :effect
            (labeled-oneof validate-clarification
                (outcome confirm
                    (and
                        (not (maybe-have_cuisine))
                        (have_cuisine)
                    )
                )
                (outcome deny
                    (and
                        (not (cuisine-value-dessert))
                        (not (cuisine-value-mexican))
                        (not (cuisine-value-chinese))
                        (not (maybe-have_cuisine))
                        (not (cuisine-value-italian))
                        (not (have_cuisine))
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
    (:action check-conflict-1-or-1
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (have_allergy)
                (have_have_allergy)
                (food_restriction-value-gluten-free)
                (cuisine-value-mexican)
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
                (cuisine-value-dessert)
                (have_allergy)
                (have_have_allergy)
                (food_restriction-value-dairy-free)
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
                (have_allergy)
                (have_have_allergy)
                (have_food_restriction)
                (cuisine-value-italian)
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
                (have_allergy)
                (have_have_allergy)
                (cuisine-value-chinese)
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
                (have_allergy)
                (have_have_allergy)
                (cuisine-value-mexican)
                (food_restriction-value-dairy-free)
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
                (cuisine-value-dessert)
                (have_allergy)
                (have_have_allergy)
                (food_restriction-value-gluten-free)
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
    (:action set-food_restriction
        :parameters()
        :precondition
            (and
                (have_food_restriction)
                (not (food_restriction-value-dairy-free))
                (not (food_restriction-value-gluten-free))
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
                (not (cuisine-value-dessert))
                (not (cuisine-value-mexican))
                (not (cuisine-value-chinese))
                (not (maybe-have_cuisine))
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