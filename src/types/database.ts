export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  graphql_public: {
    Tables: {
      [_ in never]: never
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      graphql: {
        Args: {
          extensions?: Json
          operationName?: string
          query?: string
          variables?: Json
        }
        Returns: Json
      }
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
  public: {
    Tables: {
      plant_catalogue: {
        Row: {
          flowering_windows: Json | null
          hardiness: string | null
          harvest: string | null
          harvest_windows: Json | null
          height: string | null
          id: string
          plant_type_id: string
          position: string | null
          seed_to_harvest: string | null
          source: string | null
          sowing_to_transplant: string | null
          sowing_windows: Json | null
          spacing: string | null
          suitability: Database["public"]["Enums"]["suitability_tag"][] | null
          transplant_windows: Json | null
          variety: string | null
        }
        Insert: {
          flowering_windows?: Json | null
          hardiness?: string | null
          harvest?: string | null
          harvest_windows?: Json | null
          height?: string | null
          id?: string
          plant_type_id: string
          position?: string | null
          seed_to_harvest?: string | null
          source?: string | null
          sowing_to_transplant?: string | null
          sowing_windows?: Json | null
          spacing?: string | null
          suitability?: Database["public"]["Enums"]["suitability_tag"][] | null
          transplant_windows?: Json | null
          variety?: string | null
        }
        Update: {
          flowering_windows?: Json | null
          hardiness?: string | null
          harvest?: string | null
          harvest_windows?: Json | null
          height?: string | null
          id?: string
          plant_type_id?: string
          position?: string | null
          seed_to_harvest?: string | null
          source?: string | null
          sowing_to_transplant?: string | null
          sowing_windows?: Json | null
          spacing?: string | null
          suitability?: Database["public"]["Enums"]["suitability_tag"][] | null
          transplant_windows?: Json | null
          variety?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "plant_catalogue_plant_type_id_fkey"
            columns: ["plant_type_id"]
            isOneToOne: false
            referencedRelation: "plant_types"
            referencedColumns: ["id"]
          },
        ]
      }
      plant_categories: {
        Row: {
          id: number
          name: string
        }
        Insert: {
          id?: never
          name: string
        }
        Update: {
          id?: never
          name?: string
        }
        Relationships: []
      }
      plant_types: {
        Row: {
          care: string | null
          category_id: number | null
          colour: string | null
          germination: string | null
          icon: string | null
          id: string
          kind: Database["public"]["Enums"]["plant_kind"]
          name: string
          perennial: boolean
          pests: string | null
        }
        Insert: {
          care?: string | null
          category_id?: number | null
          colour?: string | null
          germination?: string | null
          icon?: string | null
          id?: string
          kind?: Database["public"]["Enums"]["plant_kind"]
          name: string
          perennial?: boolean
          pests?: string | null
        }
        Update: {
          care?: string | null
          category_id?: number | null
          colour?: string | null
          germination?: string | null
          icon?: string | null
          id?: string
          kind?: Database["public"]["Enums"]["plant_kind"]
          name?: string
          perennial?: boolean
          pests?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "plant_types_category_id_fkey"
            columns: ["category_id"]
            isOneToOne: false
            referencedRelation: "plant_categories"
            referencedColumns: ["id"]
          },
        ]
      }
      plants: {
        Row: {
          archived_at: string | null
          catalogue_id: string | null
          created_at: string
          custom_variety: string | null
          harvest_dates: string[]
          id: string
          notes: string | null
          overrides: Json | null
          plant_type_id: string
          repot_dates: string[]
          sow_dates: string[]
          transplant_dates: string[]
          user_id: string
          year: number | null
        }
        Insert: {
          archived_at?: string | null
          catalogue_id?: string | null
          created_at?: string
          custom_variety?: string | null
          harvest_dates?: string[]
          id?: string
          notes?: string | null
          overrides?: Json | null
          plant_type_id: string
          repot_dates?: string[]
          sow_dates?: string[]
          transplant_dates?: string[]
          user_id?: string
          year?: number | null
        }
        Update: {
          archived_at?: string | null
          catalogue_id?: string | null
          created_at?: string
          custom_variety?: string | null
          harvest_dates?: string[]
          id?: string
          notes?: string | null
          overrides?: Json | null
          plant_type_id?: string
          repot_dates?: string[]
          sow_dates?: string[]
          transplant_dates?: string[]
          user_id?: string
          year?: number | null
        }
        Relationships: [
          {
            foreignKeyName: "plants_catalogue_id_fkey"
            columns: ["catalogue_id"]
            isOneToOne: false
            referencedRelation: "catalogue_with_details"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "plants_catalogue_id_fkey"
            columns: ["catalogue_id"]
            isOneToOne: false
            referencedRelation: "plant_catalogue"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "plants_plant_type_id_fkey"
            columns: ["plant_type_id"]
            isOneToOne: false
            referencedRelation: "plant_types"
            referencedColumns: ["id"]
          },
        ]
      }
      reminders: {
        Row: {
          created_at: string
          due_date: string
          id: string
          plant_id: string
          type: Database["public"]["Enums"]["task_type"]
          user_id: string
        }
        Insert: {
          created_at?: string
          due_date: string
          id?: string
          plant_id: string
          type: Database["public"]["Enums"]["task_type"]
          user_id?: string
        }
        Update: {
          created_at?: string
          due_date?: string
          id?: string
          plant_id?: string
          type?: Database["public"]["Enums"]["task_type"]
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "reminders_plant_id_fkey"
            columns: ["plant_id"]
            isOneToOne: false
            referencedRelation: "plants"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "reminders_plant_id_fkey"
            columns: ["plant_id"]
            isOneToOne: false
            referencedRelation: "plants_with_details"
            referencedColumns: ["id"]
          },
        ]
      }
    }
    Views: {
      catalogue_with_details: {
        Row: {
          care: string | null
          category_name: string | null
          colour: string | null
          flowering_windows: Json | null
          germination: string | null
          hardiness: string | null
          harvest: string | null
          harvest_windows: Json | null
          height: string | null
          icon: string | null
          id: string | null
          kind: Database["public"]["Enums"]["plant_kind"] | null
          name: string | null
          pests: string | null
          plant_type_id: string | null
          position: string | null
          seed_to_harvest: string | null
          source: string | null
          sowing_to_transplant: string | null
          sowing_windows: Json | null
          spacing: string | null
          suitability: Database["public"]["Enums"]["suitability_tag"][] | null
          transplant_windows: Json | null
          variety: string | null
        }
        Relationships: [
          {
            foreignKeyName: "plant_catalogue_plant_type_id_fkey"
            columns: ["plant_type_id"]
            isOneToOne: false
            referencedRelation: "plant_types"
            referencedColumns: ["id"]
          },
        ]
      }
      plants_with_details: {
        Row: {
          archived_at: string | null
          care: string | null
          catalogue_id: string | null
          category_name: string | null
          colour: string | null
          custom_variety: string | null
          flowering_windows: Json | null
          germination: string | null
          hardiness: string | null
          harvest: string | null
          harvest_dates: string[] | null
          harvest_windows: Json | null
          height: string | null
          icon: string | null
          id: string | null
          kind: Database["public"]["Enums"]["plant_kind"] | null
          name: string | null
          notes: string | null
          pests: string | null
          plant_type_id: string | null
          position: string | null
          repot_dates: string[] | null
          seed_to_harvest: string | null
          sow_dates: string[] | null
          sowing_to_transplant: string | null
          sowing_windows: Json | null
          spacing: string | null
          suitability: Json | null
          transplant_dates: string[] | null
          transplant_windows: Json | null
          variety: string | null
          year: number | null
        }
        Relationships: [
          {
            foreignKeyName: "plants_catalogue_id_fkey"
            columns: ["catalogue_id"]
            isOneToOne: false
            referencedRelation: "catalogue_with_details"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "plants_catalogue_id_fkey"
            columns: ["catalogue_id"]
            isOneToOne: false
            referencedRelation: "plant_catalogue"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "plants_plant_type_id_fkey"
            columns: ["plant_type_id"]
            isOneToOne: false
            referencedRelation: "plant_types"
            referencedColumns: ["id"]
          },
        ]
      }
    }
    Functions: {
      array_remove_last: {
        Args: { arr: string[]; val: string }
        Returns: string[]
      }
      complete_reminder: {
        Args: { done_on: string; reminder_id: string }
        Returns: undefined
      }
      delete_my_account: { Args: never; Returns: undefined }
      uncomplete_reminder: {
        Args: {
          done_on: string
          due: string
          for_plant: string
          reminder_id: string
          task: Database["public"]["Enums"]["task_type"]
        }
        Returns: undefined
      }
    }
    Enums: {
      plant_kind: "vegetable" | "herb" | "fruit" | "flower"
      suitability_tag: "multisow" | "interplant" | "follow-on" | "intersow"
      task_type: "sow" | "repot" | "transplant" | "harvest"
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

type DatabaseWithoutInternals = Omit<Database, "__InternalSupabase">

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends (DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never) = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] &
        DefaultSchema["Views"])
    ? (DefaultSchema["Tables"] &
        DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
        Row: infer R
      }
      ? R
      : never
    : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends (DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never) = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Insert: infer I
      }
      ? I
      : never
    : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends (DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never) = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Update: infer U
      }
      ? U
      : never
    : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema["Enums"]
    | { schema: keyof DatabaseWithoutInternals },
  EnumName extends (DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never) = never,
> = DefaultSchemaEnumNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
    ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends (PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never) = never,
> = PublicCompositeTypeNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
    ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
    : never

export const Constants = {
  graphql_public: {
    Enums: {},
  },
  public: {
    Enums: {
      plant_kind: ["vegetable", "herb", "fruit", "flower"],
      suitability_tag: ["multisow", "interplant", "follow-on", "intersow"],
      task_type: ["sow", "repot", "transplant", "harvest"],
    },
  },
} as const

